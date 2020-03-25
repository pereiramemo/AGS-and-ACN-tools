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
Usage: ./run_acn.sh <input fna> <ags tsv> <input smrana> <output directory> <options>
 
--help                          print this help
--evalue NUM                    e-value to be used in 16S rRNA filtering (default 1e-15)
--min_identity NUM              minimum identity to be used in 16S rRNA filtering (default 85)
--min_length NUM                minimum length to be used in 16S rRNA filtering (default 30)
--length_ssu NUM                16S rRNA reference length (default E. cloi: 1542bp)
--nslots NUM                    number of slots (used in SortMeRNA) (default 2)
--output_prefix CHAR            prefix output name (default sample name)
--overwrite t|f                 overwrite current directory (default f)
--sample_name CHAR              sample name (default input file name)
--save_complementary_data t|f   save data used to compute the average genome size (default f)
--smrna_mem NUM                 Mbytes used to load reads into memory (used in SortMeRNA) (default 1024; maximum 4096)
--verbose t|f                   run verbosely (default f)


<input fna>: fasta file to annotate the 16S rRNA genes (optional)
<ags tsv>: ags.sh output (used to parse the NGs)
<input smrna>: precomputed sortmerna blast output

EOF
}

###############################################################################
# 3. Parse input parameters
###############################################################################

while :; do
  case "${1}" in
    --help) # Call a "show_help" function to display a synopsis, then exit.
    show_usage
    exit 1;
    ;;
#############
  --evalue)
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
  --input_fna)
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
  --input_ags)
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
  --input_smrna)
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
  --min_identity)
  if [[ -n "${2}" ]]; then
    MIN_IDENTITY="${2}"
    shift
  fi
  ;;
  --min_identity=?*)
  MIN_IDENTITY="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --min_identity=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  --min_length)
  if [[ -n "${2}" ]]; then
   MIN_LENGTH="${2}"
   shift
  fi
  ;;
  --min_length=?*)
  MIN_LENGTH="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --min_length=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  --length_ssu)
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
  --output_prefix)
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
  --outdir)
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
  --sample_name)
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
  --save_complementary_data)
  if [[ -n "${2}" ]]; then
    SAVE_COMPLEMENTARY_DATA="${2}"
    shift
  fi
  ;;
  --save_complementary_data=?*)
  SAVE_COMPLEMENTARY_DATA="${1#*=}" # Delete everything up to "=" and assign the 
                                    # remainder.
  ;;
  --save_complementary_data=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  --nslots)
  if [[ -n "${2}" ]]; then
    NSLOTS="${2}"
    shift
  fi
  ;;
  --nslots=?*)
  NSLOTS="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --nslots=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  --verbose)
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
  --overwrite)
  if [[ -n "${2}" ]]; then
    OVERWRITE="${2}"
    shift
  fi
  ;;
  --overwrite=?*)
  OVERWRITE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --overwrite=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;; 
#############  
  --smrna_mem)
  if [[ -n "${2}" ]]; then
    SMRNA_MEM="${2}"
    shift
  fi
  ;;
  --smrna_mem=?*)
  SMRNA_MEM="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --smrna_mem=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
############ # End of all options.
  --)              
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
  echo  "See: run_acn.sh . . . --help"
  exit 1
fi

if [[ ! -f "${INPUT_AGS}" ]]; then
  echo "Please input the ags tsv file"
  echo  "See: run_acn.sh . . . --help"
  exit 1
fi

###############################################################################
# 5. Define defaults
###############################################################################

if [[ -z "${SAMPLE}" && -f "${INPUT_FNA}" ]]; then
  SAMPLE=$(basename  "${INPUT_FNA}" | \
           sed -e "s/.fa$//" -e "s/.fna$//" -e "s/.fasta$//")
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

if [[ -z "${MIN_IDENTITY}" ]]; then
  MIN_IDENTITY=85
fi

if [[ -z "${EVALUE}" ]]; then
  EVALUE=1e-15
fi

if [[ -z "${MIN_LENGTH}" ]]; then
  MIN_LENGTH=30
fi

if [[ -z "${LENGTH_SSU}" ]]; then
  LENGTH_SSU=1542
fi

if [[ -z "${SMRNA_MEM}" ]]; then
  SMRNA_MEM=1024
fi

###############################################################################
# 6. Check output directories
###############################################################################

if [[ -d "${OUTDIR_LOCAL}/${OUTDIR_EXPORT}" ]]; then
  if [[ "${OVERWRITE}" != "t" ]]; then
    echo "${OUTDIR_EXPORT} already exists. Use \"--overwrite t\" to overwrite"
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
rm -r "${THIS_JOB_TMP_DIR}"
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

NG=$(cat "${INPUT_AGS}" | sed -n 2p | cut -f3)

if [[ -z "${NG}" ]]; then
  echo "Parsing ags.sh output failed"
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
    echo "SortMeRNA failed"
    exit 1
  fi

  INPUT_SMRNA="${SMRNA_OUT}".blast

   if [[ ! -f "${INPUT_SMRNA}" ]]; then
    echo "SortMeRNA failed (no output file generated)"
    exit 1
  fi
  
fi

###############################################################################
# 11. Compute 16S rRNA gene coverage
###############################################################################

echo "Computing ACN ..." 2>&1 | handleoutput

COVERAGE_16S=$( awk -v l="${MIN_LENGTH}" -v i="${MIN_IDENTITY}" \
                    -v e="${EVALUE}" -v s=${LENGTH_SSU} '{

  if ( $11 <= e && $4 >= l && $3 >= i ) {
    n_nuc = $10 -$9 +1;
    n_nuc = sqrt(n_nuc*n_nuc)
    n_nuc_tot = n_nuc + n_nuc_tot
  }

} END {

  print n_nuc_tot/s

}' "${INPUT_SMRNA}")

if [[ $? != 0 ]]; then
  echo "Compute 16S rRNA coverage failed"
  exit 1
fi

if [[ -z "${COVERAGE_16S}" ]]; then
  echo "Compute 16S rRNA coverage failed (awk)"
  exit 1
fi

###############################################################################
# 12. Compute 16S rRNA gene average copy number
###############################################################################

ACN=$(echo "scale=6; ${COVERAGE_16S}/(${NG})" | bc -l)

if [[ -z "${ACN}" ]]; then
  echo "Compute 16S rRNA coverage failed (bc)"
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
