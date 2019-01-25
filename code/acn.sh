#!/bin/bash

###############################################################################
# 1. Set environment
###############################################################################

source /bioinfo/software/conf

set -o pipefail

###############################################################################
# 2. Define help
###############################################################################

show_usage(){
  cat <<EOF
See run_acn.sh . . . --help
  Usage: ./acn.sh <input fna> <ags tsv> <input smrana> <output directory> <options>
  [-h|--help] [-e|--evalue NUM] [-id|--identity NUM]
  [-l|--length NUM] [-ls|--length_ssu NUM] [-o|--output_prefix CHAR] 
  [-s|--sample_name CHAR] [-scd|--save_completentary_data t|f] [-t|--nslots NUM]

-h, --help print this help
-e, --evalue  maximum evalue to be used in 16S rRNA filtering (default 1e-15)
-id, --identity minimum identity to be used in 16S rRNA filtering (default 85)
-l, --length minimum length to be used in 16S rRNA filtering (default 30)
-ls, --length_ssu 16S rRNA reference length (default E. cloi: 1542bp)
-o, --output_prefix prefix output name (default sample name)
-s, --sample_name sample name (default input file name)
-scd, --save_complementary_data t or f, save data used to compute the average genome size (default f)
-t, --nslots  number of slots (used in SortMeRNA) (default 2)
-v, --verbose   t or f, run verbosely (default f)
-w, --overwrite t or f, overwrite current directory (default f)

<input smrna>: precomputed sortmerna blast output
<ags tsv>: ags.sh output (used to parse the NGs)
<input fasta>: fasta file to annotate the 16S rRNA genes (optional)

EOF
}

###############################################################################
# 3. Parse input parameters
###############################################################################

while :; do
  case "${1}" in

    -h|-\?|--help) # Call a "show_help" function to display a synopsis, then
                   # exit.
    show_usage
    exit 1;
    ;;
#############
  -e|--evalue)
  if [[ -n "${2}" ]]; then
   EVALUE="${2}"
   shift
  fi
  ;;
  --evalue=?*)
  EVALUE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --evalue=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  -i|--input_fna)
  if [[ -n "${2}" ]]; then
   INPUT_FNA="${2}"
   shift
  fi
  ;;
  --input_fna=?*)
  INPUT_FNA="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --input_fna=) # Handle the empty case
  printf "ERROR: --input_fna requires a non-empty option argument.\n"  >&2
  exit 1
  ;;
#############
  -i|--input_ags)
  if [[ -n "${2}" ]]; then
   INPUT_AGS="${2}"
   shift
  fi
  ;;
  --input_ags=?*)
  INPUT_AGS="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --input_ags=) # Handle the empty case
  printf "ERROR: --input_ags requires a non-empty option argument.\n"  >&2
  exit 1
  ;;  
#############
  -is|--input_smrna)
  if [[ -n "${2}" ]]; then
   INPUT_SMRNA="${2}"
   shift
  fi
  ;;
  --input_smrna=?*)
  INPUT_SMRNA="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --input_smrna=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  -id|--identity)
  if [[ -n "${2}" ]]; then
   IDENTITY="${2}"
   shift
  fi
  ;;
  --identity=?*)
  IDENTITY="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --identity=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  -l|--length)
  if [[ -n "${2}" ]]; then
   LENGTH="${2}"
   shift
  fi
  ;;
  --length=?*)
  LENGTH="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --length=) # Handle the empty case
    printf 'Using default environment.\n' >&2
  ;;
#############
  -ls|--length_ssu)
  if [[ -n "${2}" ]]; then
   LENGTH_SSU="${2}"
   shift
  fi
  ;;
  --length_ssu=?*)
  LENGTH_SSU="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --length_ssu=) # Handle the empty case
    printf 'Using default environment.\n' >&2
  ;;  
#############
  -o|--output_prefix)
  if [[ -n "${2}" ]]; then
   OUTPUT_PREFIX="${2}"
   shift
  fi
  ;;
  --output_prefix=?*)
  OUTPUT_PREFIX="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --output_prefix=) # Handle the empty case
    printf 'Using default environment.\n' >&2
  ;;
#############
  -od|--outdir)
   if [[ -n "${2}" ]]; then
     OUTDIR_EXPORT="${2}"
     shift
   fi
  ;;
  --outdir=?*)
  OUTDIR_EXPORT="${1#*=}" # Delete everything up to "=" and assign the 
                          # remainder.
  ;;
  --outdir=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  -s|--sample_name)
  if [[ -n "${2}" ]]; then
   SAMPLE="${2}"
   shift
  fi
  ;;
  --sample_name=?*)
  SAMPLE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --sample_name=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  -scd|--save_complementary_data)
  if [[ -n "${2}" ]]; then
   SAVE_COMPLEMENTARY_DATA="${2}"
   shift
  fi
  ;;
  --save_complementary_data=?*)
  SAVE_COMPLEMENTARY_DATA="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --save_complementary_data=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
 #############
  -t|--nslots)
   if [[ -n "${2}" ]]; then
     NSLOTS="${2}"
     shift
   fi
  ;;
  --nslots=?*)
  NSLOTS="${1#*=}" # Delete everything up to "=" and assign the
# remainder.
  ;;
  --nslots=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
-v|--verbose)
   if [[ -n "${2}" ]]; then
     VERBOSE="${2}"
     shift
   fi
  ;;
  --verbose=?*)
  VERBOSE="${1#*=}" # Delete everything up to "=" and assign the
                    # remainder.
  ;;
  --verbose=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############  
  -w|--overwrite)
   if [[ -n "${2}" ]]; then
     OVERWRITE="${2}"
     shift
   fi
  ;;
  --overwrite=?*)
  OVERWRITE="${1#*=}" # Delete everything up to "=" and assign the
# remainder.
  ;;
  --overwrite=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;; 
############
    --)              # End of all options.
    shift
    break
    ;;
    -?*)
    printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
    ;;
    *) # Default case: If no more options then break out of the loop.
    break
    esac
    shift
done

###############################################################################
# 4. Check input data
###############################################################################

if [[ ! -f "${INPUT_FNA}" ]]; then
  echo "Please input the fna file"
  echo  "See: acn.sh --help"
  exit 1
fi

if [[ ! -f "${INPUT_AGS}" ]]; then
  echo "Please input the ags tsv file"
  echo  "See: acn.sh --help"
  exit 1
fi

###############################################################################
# 5. Define defaults
###############################################################################

if [[ -z "${SAMPLE}" && -f "${INPUT_FNA}" ]]; then
  SAMPLE=$(basename  "${INPUT_FNA}" | \
           sed -e "s/.fa$//" -e "s/.faa$//" -e "s/.fasta$//")
fi

if [[ -z "${SAMPLE}" && ! -f "${INPUT_FNA}" && -f "${INPUT_SMRNA}" ]]; then
  SAMPLE=$(basename  "${INPUT_SMRNA}" | \
           sed -e "s/\.[^\.]\+$//")
fi

if [[ -z "${SAVE_COMPLEMENTARY_DATA}" ]]; then
  SAVE_COMPLEMENTARY_DATA="f"
fi

if [[ -z "${OUTPUT_PREFIX}" ]]; then
  OUTPUT_PREFIX="${SAMPLE}"
fi

if [[ -z "${NSLOTS}" ]]; then
  NSLOTS=2
fi

if [[ -z "${IDENTITY}" ]]; then
  IDENTITY=85
fi

if [[ -z "${EVALUE}" ]]; then
  EVALUE=1e-15
fi

if [[ -z "${LENGTH}" ]]; then
  LENGTH=30
fi

if [[ -z "${LENGTH_SSU}" ]]; then
  LENGTH_SSU=1542
fi

###############################################################################
# 6. Check output directories
###############################################################################

if [[ -d "${OUTDIR_LOCAL}/${OUTDIR_EXPORT}" ]]; then
  if [[ "${OVERWRITE}" != "t" ]]; then
    echo "${OUTDIR_EXPORT} already exist. Use \"--overwrite t\" to overwrite."
    exit
  fi
fi

###############################################################################
# 7. Create output directories
###############################################################################

THIS_JOB_TMP_DIR="${SCRATCH}/${OUTDIR_EXPORT}"

if [[ ! -d "${THIS_JOB_TMP_DIR}" ]]; then
  mkdir -p "${THIS_JOB_TMP_DIR}"
fi

###############################################################################
# 8. Define functions
###############################################################################

# functions
function cleanup {
rm "${THIS_JOB_TMP_DIR}"/"${OUTPUT_PREFIX}.blast"
rm "${THIS_JOB_TMP_DIR}"/"${OUTPUT_PREFIX}.log"
rm "${THIS_JOB_TMP_DIR}"/"${OUTPUT_PREFIX}_acn.tsv"
}

# trap
trap cleanup SIGINT SIGKILL SIGTERM ERR

if [[ "${VERBOSE}" == "t" ]]; then
  function handleoutput {
    cat /dev/stdin | \
    while read STDIN; do 
      echo "${STDIN}"
    done  
  }
else
  function handleoutput {
  cat /dev/stdin >/dev/null
}
fi

###############################################################################
# 9. Parse ags.sh output
###############################################################################

NG=$( cat "${INPUT_AGS}" | sed -n 2p | cut -f3)

if [[ -z "${NG}" ]]; then
  echo "parsing ags.sh output failed"
  exit 1
fi

###############################################################################
# 10. Annotate 16S rRNA genes
###############################################################################

if [[ ! -f "${INPUT_SMRNA}" ]]; then

echo "Identifying 16S rRNA genes ..."  2>&1 | handleoutput

SMRNA_OUT="${THIS_JOB_TMP_DIR}/${OUTPUT_PREFIX}"_smrna

  "${sortmerna}" \
    --reads "${INPUT_FNA}" \
    -a "${NSLOTS}" \
    --ref "${REF}" \
    --blast 1 \
    --fastx \
    --aligned "${SMRNA_OUT}" \
    --log \
    -m "${SMRNA_MEM}" \
    -e 1e-1 \
    --best 1  2>&1 | handleoutput

  if [[ $? != 0 ]]; then
    echo "sormerna failed"
    exit 1
  fi

  INPUT_SMRNA="${SMRNA_OUT}".blast

   if [[ ! -f "${INPUT_SMRNA}" ]]; then
    echo "sormerna failed"
    exit 1
  fi
  
fi

###############################################################################
# 11. Compute 16S rRNA gene coverage
###############################################################################

echo "Computing ACN ..." 2>&1 | handleoutput

COVERAGE_16S=$( awk -v l="${LENGTH}" -v i="${IDENTITY}" \
                    -v e="${EVALUE}" -v s=${LENGTH_SSU} '{

  if ( $11 <= e && $4 >= l && $3 >= i ) {
    n_nuc = $10 -$9 +1;
    n_nuc = sqrt(n_nuc*n_nuc)
    n_nuc_tot = n_nuc + n_nuc_tot
  }

} END {

  print n_nuc_tot/s

} ' "${INPUT_SMRNA}")

if [[ $? != 0 ]]; then
  echo "compute 16S coverage failed"
  exit 1
fi

if [[ -z "${COVERAGE_16S}" ]]; then
  echo "compute 16S coverage failed (awk)"
  exit 1
fi

###############################################################################
# 12. Compute 16S rRNA gene average copy number
###############################################################################

ACN=$(echo "scale=6; ${COVERAGE_16S}/(${NG})" | bc -l)

if [[ -z "${ACN}" ]]; then
  echo "compute 16S coverage failed (bc)"
  exit 1
fi

###############################################################################
# 13. Create output
###############################################################################

OUTPUT_ACN="${THIS_JOB_TMP_DIR}/${OUTPUT_PREFIX}"_acn.tsv
echo -e "Sample\tACN\n${SAMPLE}\t${ACN}" > "${OUTPUT_ACN}"

###############################################################################
# 14. Clean up
###############################################################################

if  [[ ! "${SAVE_COMPLEMENTARY_DATA}" =~ [T|t] ]]; then
  rm "${THIS_JOB_TMP_DIR}/${OUTPUT_PREFIX}".blast
  rm "${THIS_JOB_TMP_DIR}/${OUTPUT_PREFIX}".log
  rm "${THIS_JOB_TMP_DIR}/${OUTPUT_PREFIX}".fasta
fi

###############################################################################
# 15. Move output for export
###############################################################################

rsync -a --delete "${THIS_JOB_TMP_DIR}" "${OUTDIR_LOCAL}"


