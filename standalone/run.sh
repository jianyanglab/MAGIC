#!/usr/bin/env bash

set -euo pipefail

get_config_as_path() {
  local yq_filter=$1
  if [[ -z "$yq_filter" ]]; then
    echo "usage: get_config_as_path <yq_filter>" >&2
    return 2
  fi

  command -v yq >/dev/null 2>&1 || { echo "get_config_as_path: yq not found" >&2; return 1; }
  command -v realpath >/dev/null 2>&1 || { echo "get_config_as_path: realpath not found" >&2; return 1; }

  local target
  target=$(yq -r $yq_filter ${CONFIG}) || return 1
  [[ -n "$target" ]] || { echo "get_config_as_path: $yq_filter missing/empty in $CONFIG" >&2; return 1; }

  echo "${MAGIC_ROOT}/${target}"
}

# Resolve magic root 
export MAGIC_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd -P)"
export MAGIC_RUNTIME=$(mktemp -d -t magic_runtime_XXXXXX)

# Setup config.yaml
cp $MAGIC_ROOT/config.yaml $MAGIC_RUNTIME/
export CONFIG=$MAGIC_RUNTIME/config.yaml

# prepend path
export PATH=$MAGIC_ROOT/softwares:$PATH

export trait_name=$(yq -r .input.trait ${CONFIG})
export SMR=$(get_config_as_path '.software.smr')
export REFERENCE=$(get_config_as_path ".reference.reference_bfile")
export GWAS_DATA=$(get_config_as_path ".input.gwas")
export QTL_list=$(get_config_as_path ".input.user_xQTL_list")
export SCRIPT_DIR=$(get_config_as_path ".script.path")
export OUTPUT=$(yq -r ".input.output" ${CONFIG})

export plink1_9=$(get_config_as_path ".software.plink1_9")
export epi_to_bed=$(get_config_as_path ".software.epi_to_bed")
export user_e2g_list=$(yq -r ".input.user_e2g_list" ${CONFIG})
export user_xQTL_list=$(yq -r ".input.user_xQTL_list" ${CONFIG})
export get_concensus_link=$(yq -r ".software.get_concensus_link" ${CONFIG})
export genome_hg38="${MAGIC_ROOT}/../share/GRCh38.genome"
export user_xQTL_link_consensus=$(yq -r '.input.user_xQTL_link_consensus' ${CONFIG})
export reference_all_bim=$MAGIC_ROOT/../share/BED_ukbEUR_imp_v3_INFO0.8_maf0.01_mind0.05_geno0.05_hwe1e6_10K_hg38_chrALL.bim

export gencode_file="$MAGIC_ROOT/../share/gencode.v40.GRCh38.gene.annotation.bed"
export CpG_link_file="$MAGIC_ROOT/../share/CpG_consensus_all.link"
export hQTL_link_file="$MAGIC_ROOT/../share/hQTL_consensus_all.link"
export caQTL_link_file="$MAGIC_ROOT/../share/caQTL_consensus_all.link"

export reference_bim_file=$(yq -r .reference.reference_all_bim ${CONFIG})
export user_xQTL_name_list=$(yq -r .input.user_xQTL_name_list ${CONFIG})
export user_xQTL_link_consensus=$(yq -r .input.user_xQTL_link_consensus ${CONFIG})



function usage {
    echo "usage: xmagic --trait-name <trait-name> --gwas-summary <gwas summary path> --bfile <referece bfile path> --besd-flist <besd file path> --e2g-flist <e2g file path> --out <output directory> --chr <chromosome range or index>"
    echo "   ";
    echo "  --gwas-summary : GWAS summary statistics file (format similar to GCTA-COJO: https://yanglab.westlake.edu.cn/software/gcta/#COJO).";
    echo "  --bfile        : PLINK binary files (.bed, .bim, .fam) for LD reference.";
    echo "  --besd-flist   : A file listing paths to multiple xQTL BESD files (format similar to SMR: https://yanglab.westlake.edu.cn/software/smr/#DataManagement). These can include eQTLs, sQTLs, pQTLs, mQTLs, haQTLs, etc";
    echo "  --e2g-flist    : A text file listing paths to multiple functional element-to-gene mapping files.";
    echo "  --out          : Prefix for output files, including gene-trait association p-values (.genes.ppa)."
    echo "  --chr          : Chromosome range or index, e.g. '1-22' or 1."
    echo "  --trait-name   : Trait name."
    echo "  --verbose      : Print verbose information. Useful for debugging."
    echo "  --help         : This message";
}

function parse_args {
    # positional args
    args=()
    gwas=""
    reference_bfile=""
    xqtl_list=""
    e2g_list=""
    chr="1-22"
    output="output"
    verbose=0

    # named args
    while (( $# )); do
        case "$1" in
            --gwas-summary ) gwas="$2";            shift;;
            --bfile )        reference_bfile="$2"; shift;;
            --besd-flist )   xqtl_list="$2";       shift;;
            --e2g-flist )    e2g_list="$2";        shift;;
            --chr )          chr="$2";             shift;;
            --out )          output="$2";          shift;;
            --trait-name )   trait_name="$2";      shift;;
            --verbose )      verbose=1;;
            -h | --help )    usage;                exit;; 
            * )              usage;                exit;;
        esac
        shift # move to next kv pair
    done

    # validate required args
    if [[ -z "${gwas}" || -z "${reference_bfile}" || -z "${xqtl_list}" || -z "${e2g_list}" ]]; then
        echo "Invalid arguments"
        usage
        exit;
    fi
}

function run {
    parse_args "$@"

    if [[ -z "$chr" ]]; then
        chr1=1
        chr2=22
    else
        IFS='-' read -r chr1 chr2 <<< "$chr"
        if [[ -z "$chr1" ]] && [[ -z "$chr2" ]]; then
            chr1=1
            chr2=22
        elif [[ ! -z "$chr1" ]] && [[ -z "$chr2" ]]; then
            chr2=$chr1
        elif [[ ! -z "$chr1" ]] && [[ ! -z "$chr2" ]]; then
            chr1=$chr1
            chr2=$chr2
        else
            chr1=1
            chr2=22
        fi
    fi

    if ! (( $chr1 >= 1 && $chr2 <= 22  && $chr1 <= $chr2)); then
        echo "Invalid chromosome index!"
        exit 1;
    fi

    # Setup R lang env
    export RLANG_ENV=$MAGIC_RUNTIME/rlang_env
    mkdir -p $RLANG_ENV
    tar -xf $MAGIC_ROOT/../share/magic_renv.tar -C $RLANG_ENV/
    $RLANG_ENV/bin/conda-unpack

    # Force R to use only the bundled env libraries
    export R_LIBS_USER=
    export R_LIBS_SITE=
    export R_BIN=$RLANG_ENV/bin/Rscript
    export bedtools=$RLANG_ENV/bin/bedtools

    export GWAS_DATA=$gwas
    export QTL_list=$xqtl_list
    export user_xQTL_list=$QTL_list
    export user_e2g_list=$e2g_list
    export REFERENCE=$reference_bfile
    export OUTPUT="${output}_$(date +%Y%m%d_%H%M%S)"
    export QTL_list_num=$(cat ${QTL_list} | wc -l)

    if [[ $verbose -eq 1 ]]; then
        echo "Environments:"
        echo "  R_BIN=${R_BIN}"
        echo "  GWAS_DATA=${GWAS_DATA}"
        echo "  QTL_list=${QTL_list}"
        echo "  user_e2g_list=${user_e2g_list}"
        echo "  REFERENCE=${REFERENCE}"
        echo "  QTL_list_num=${QTL_list_num}"
        echo "  chr1=${chr1}, chr2=${chr2}"
        echo "  trait_name=${trait_name}"
        echo "  OUTPUT=${OUTPUT}"
        echo "  bedtools=${bedtools}"
    fi

    yq -i ".input.gwas = \"$GWAS_DATA\"" $CONFIG
    yq -i ".reference.reference_bfile = \"$REFERENCE\"" $CONFIG
    yq -i ".input.user_e2g_list = \"$user_e2g_list\"" $CONFIG
    yq -i ".input.user_xQTL_list = \"$QTL_list\"" $CONFIG
    yq -i ".input.output = \"$OUTPUT\"" $CONFIG
    yq -i ".input.trait = \"$trait_name\"" $CONFIG
    yq -i ".link_annotation.genome_hg38 = \"$genome_hg38\"" $CONFIG
    yq -i ".reference.reference_all_bim = \"$reference_all_bim\"" $CONFIG

    yq -i ".gene.gencode = \"$gencode_file\"" ${CONFIG}
    yq -i ".magic.CpG_link = \"$CpG_link_file\"" ${CONFIG}
    yq -i ".magic.hQTL_link = \"$hQTL_link_file\"" ${CONFIG}
    yq -i ".magic.caQTL_link = \"$caQTL_link_file\"" ${CONFIG}



    # Run scripts
    ${SCRIPT_DIR}/run_clumping.sh $CONFIG $chr1 $chr2
    ${SCRIPT_DIR}/run_step_0.sh $CONFIG $chr1 $chr2

    for qtl_i in $(seq ${QTL_list_num}); do
        ${SCRIPT_DIR}/run_smr.sh $CONFIG ${qtl_i} $chr1 $chr2
    done

    ${SCRIPT_DIR}/run_magic.sh $CONFIG
}

echo `date`
run "$@";
echo `date`

# Clear R lang env
rm -rf $RLANG_ENV
