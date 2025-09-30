#!/usr/bin/env sh


CONFIG=config.yaml

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
  [[ -n "$target" ]] || { echo "get_config_as_path: $yq_filter missing/empty in $config" >&2; return 1; }

  realpath --relative-to=${MAGIC_ROOT} -- ${target}
}

# Resolve magic root 
export MAGIC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"
# Force R to use only the bundled env libraries
export R_LIBS_USER=
export R_LIBS_SITE=
# Use env Rscript
export R_BIN="${MAGIC_ROOT}/env/bin/Rscript"

export trait_name=$(yq -r .input.trait ${CONFIG})
export SMR=$(get_config_as_path '.software.smr')
export REFERENCE=$(get_config_as_path ".reference.reference_bfile")
export GWAS_DATA=$(get_config_as_path ".input.gwas")
export QTL_list=$(get_config_as_path ".input.user_xQTL_list")
export SCRIPT_DIR=$(get_config_as_path ".script.path")
export OUTPUT=$(get_config_as_path ".input.output")

export plink1_9=$(get_config_as_path ".software.plink1_9")
export user_e2g_list=$(get_config_as_path ".input.user_e2g_list")
export user_xQTL_list=$(get_config_as_path ".input.user_xQTL_list")
export epi_to_bed=$(get_config_as_path ".software.epi_to_bed")
export bedtools=$(get_config_as_path ".software.bedtools")
export get_concensus_link=$(get_config_as_path ".software.get_concensus_link")
export genome_hg38=$(get_config_as_path ".link_annotation.genome_hg38")
export user_xQTL_link_consensus=$(get_config_as_path '.input.user_xQTL_link_consensus')

function usage {
    echo "usage: xmagic --gwas <gwas_path> --reference_bfile <referece_bfile_path> --xqtl <xQTL list file path> --e2g <e2g list file path> --chr <chromosome range or index>"
    echo "   ";
    echo "  --gwas            : GWAS data path";
    echo "  --reference_bfile : Referece bed file path";
    echo "  --xqtl            : xQTL list file path";
    echo "  --e2g             : e2g list file path";
    echo "  --chr             : Chromosome range or index, e.g. 1,22 or 1"
    echo "  --help            : This message";
}

function parse_args {
    # positional args
    args=()

    # named args
    while [ "$1" != "" ]; do
        case "$1" in
            --gwas )            gwas="$2";            shift;;
            --reference_bfile ) reference_bfile="$2"; shift;;
            --xqtl )            xqtl_list="$2";       shift;;
            --e2g )             e2g_list="$2";        shift;;
            --chr )             chr="$2";             shift;;
            -h | --help )       usage;                exit;; 
            * )                 usage;                exit;;
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

    echo "GAWS: $gwas"
    echo "reference_bfile: $reference_bfile"
    echo "xQTL: $xqtl_list"
    echo "e2g: $e2g_list"
    echo "chr: $chr"

    if [[ -z "$chr" ]]; then
        chr1=1
        chr2=22
    else
        IFS=',' read -r chr1 chr2 <<< "$chr"
        if [[ -z "$chr1" ]] && [[ -z "$chr2" ]]; then
            chr1=1
            chr2=2
        elif [[ ! -z "$chr1" ]] && [[ -z "$chr2" ]]; then
            chr2=$chr1
        else
            chr1=1
            chr2=22
        fi
    fi

    if ! (( $chr1 >= 1 && $chr2 <= 22  && $chr1 <= $chr2)); then
        echo "Invalid chromosome index!"
        exit 1;
    fi

    export GWAS_DATA=$gwas
    export QTL_list=$xqtl_list
    export user_e2g_list=$e2g_list
    export REFERENCE=$reference_bfile
    export QTL_list_num=$(cat ${QTL_list} | wc -l)

    yq -i ".input.gwas = \"$GWAS_DATA\"" $CONFIG
    yq -i ".reference.reference_bfile = \"$REFERENCE\"" $CONFIG
    yq -i ".input.user_e2g_list = \"$user_e2g_list\"" $CONFIG
    yq -i ".input.user_xQTL_list = \"$QTL_list\"" $CONFIG

    # Run scripts
    ${SCRIPT_DIR}/run_clumping.sh config.yaml $chr1 $chr2
    ${SCRIPT_DIR}/run_step_0.sh config.yaml $chr1 $chr2

    for qtl_i in $(seq ${QTL_list_num}); do
        ${SCRIPT_DIR}/run_smr.sh config.yaml ${qtl_i} $chr1 $chr2
    done

    ${SCRIPT_DIR}/run_magic.sh config.yaml
}

echo `date`
run "$@";
echo `date`
