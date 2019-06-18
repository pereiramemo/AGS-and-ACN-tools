#!/bin/bash

###############################################################################
# 1. set environment
###############################################################################

set -o pipefail

source /bioinfo/software/conf

###############################################################################
# 2. Define help
###############################################################################

show_usage(){
  cat <<EOF
Usage: ./run_ags.sh <input fna> <input orfs> <output directory> <options>
  [-h|--help] [-b|-bp_total INT] [-lf|--min_length INT] [-lt|--max_length INT]
  [-o|--output_prefix CHAR] [-s|--sample_name CHAR] [-scd|--save_completentary_data t|f]
  [-t|--nslots INT] [-v|--verbose t|f] [-w|--overwrite t|f]

-h, --help  print this help
-b, --bp_total total number of base pairs. It will be computed if not given
-lf, --min_length  minimum length used to filter reads by length
-lt, --max_length  maximum length used to trim reads
-o, --output_prefix prefix output name (default sample name)
-s, --sample_name sample name (default input file name)
-scd, --save_complementary_data t or f, save data used to compute the average genome size (default f)
-t, --nslots  number of slots (used in UProC and FraggeneScanPlus) (default 2)
-v, --verbose   t or f, run verbosely (default f)
-w, --overwrite t or f, overwrite current directory (default f)

<input orfs>: ORFs fasta file used to annotate the single copy genes
<input fna>: Fasta file used to predict ORFs (if no ORFs file is given); This file will be also used to compute the total number of base pairs

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
  -b|--bp_total)
  if [[ -n "${2}" ]]; then
   BP_TOTAL="${2}"
   shift
  fi
  ;;
  --bp_total=?*)
  BP_TOTAL="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --bp_total=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  -io|--input_orfs)
  if [[ -n "${2}" ]]; then
   INPUT_ORFS="${2}"
   shift
  fi
  ;;
  --input_orfs=?*)
  INPUT_ORFS="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --input_orfs=) # Handle the empty case
  printf "ERROR: --input_orfs requires a non-empty option argument.\n"  >&2
  exit 1
  ;;
#############
  -ia|--input_fna)
  if [[ -n "${2}" ]]; then
   INPUT_FNA="${2}"
   shift
  fi
  ;;
  --input_fna=?*)
  INPUT_FNA="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --input_fna=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  -lt|--min_length)
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
  -lt|--max_length)
  if [[ -n "${2}" ]]; then
   MAX_LENGTH="${2}"
   shift
  fi
  ;;
  --max_length=?*)
  MAX_LENGTH="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --max_length=) # Handle the empty case
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

if [[ ! -f "${INPUT_FNA}" && ! -f "${INPUT_ORFS}" ]]; then
  echo "Please input a fasta file (fna or faa)."
  echo "See: ags.sh --help"
  exit 1
fi

if [[ ! -f "${INPUT_FNA}" && -z "${BP_TOTAL}" ]]; then
  echo "Please input the fna file or the total number of base pairs (i.e., --bp_total)."
  echo "See: ags.sh --help"
  exit 1
fi

###############################################################################
# 5. Check output directories
###############################################################################

if [[ -d "${OUTDIR_LOCAL}/${OUTDIR_EXPORT}" ]]; then
  if [[ "${OVERWRITE}" != "t" ]]; then
    echo "${OUTDIR_EXPORT} already exist. Use \"--overwrite t\" to overwrite."
    exit
  fi
fi

###############################################################################
# 6. Create output directories
###############################################################################

THIS_JOB_TMP_DIR="${SCRATCH}/${OUTDIR_EXPORT}"

if [[ ! -d "${THIS_JOB_TMP_DIR}" ]]; then
  mkdir -p "${THIS_JOB_TMP_DIR}"
fi

###############################################################################
# 5. Define defaults
###############################################################################

# define SAMPLE as INPUT_ORFS file name (is $SAMPLE is empty)
if [[ -z "${SAMPLE}" && -f "${INPUT_ORFS}" ]]; then
  SAMPLE=$(basename  "${INPUT_ORFS}" | \
           sed -e "s/.fa$//" -e "s/.faa$//" -e "s/.fasta$//")
fi

# define SAMPLE as INPUT_FNA file name (is $SAMPLE is empty)
if [[ -z "${SAMPLE}" && ! -f "${INPUT_ORFS}" && -f "${INPUT_FNA}" ]]; then
  SAMPLE=$(basename  "${INPUT_FNA}" | \
           sed -e "s/.fa$//" -e "s/.fna$//" -e  "s/.fasta$//")
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

###############################################################################
# 6. Define functions
###############################################################################

function cleanup {
rm -r "${THIS_JOB_TMP_DIR}"
}

# trap
# trap cleanup SIGINT SIGKILL SIGTERM ERR

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
# 7. Filter by length
###############################################################################

if [[ -f "${INPUT_FNA}" ]]; then

  if [[ -n "${MAX_LENGTH}" || -n "${MIN_LENGTH}" ]]; then

    if [[ -z "${MIN_LENGTH}" ]]; then
      MIN_LENGTH=10
    fi

    if [[ -n "${MAX_LENGTH}" ]]; then
      MAX_LENGTH="$(( ${MAX_LENGTH} -1))"
    else
      MAX_LENGTH=-1
    fi

    INPUT_FNA_FBL="${THIS_JOB_TMP_DIR}"/"${OUTPUT_PREFIX}"_FBL.fna

    echo "Filtering by length ..." 2>&1 | handleoutput

    "${bbduk}" \
    overwrite=t \
    out="${INPUT_FNA_FBL}" \
    in="${INPUT_FNA}" \
    minlength="${MIN_LENGTH}" \
    forcetrimright="${MAX_LENGTH}" \
    threads="${NSLOTS}" 2>&1 | handleoutput

    if [[ $? != 0 ]]; then
      echo "bbduk trim and filter by length failed"
      exit 1
    fi

    INPUT_FNA="${INPUT_FNA_FBL}"

    if [[ ! -f "${INPUT_FNA}" ]]; then
      echo "bbduk trim and filter by length failed"
      exit 1
    fi

    BBDUKFILTER=1

  fi
fi

###############################################################################
# 8. Compute number of base pairs
###############################################################################

# count the total number of bp, if not given
if [[ -f "${INPUT_FNA}"  && -z "${BP_TOTAL}" ]]; then

  echo "Counting bps ..." 2>&1 | handleoutput

  BP_TOTAL=$(egrep -v "^>" "${INPUT_FNA}" | wc | awk '{ print $3-$1}')

  if [[ $? != 0 ]]; then
    echo "compute average read length failed"
    exit 1
  fi

  if [[ -z "${BP_TOTAL}" ]]; then
    echo "compute average read length failed"
    exit 1
  fi

fi

###############################################################################
# 9. Predict orfs
###############################################################################

if [[ ! -f "${INPUT_ORFS}" ]]; then

  echo "Predicting ORFs ..." 2>&1 | handleoutput

  ORFS_OUT="${THIS_JOB_TMP_DIR}"/"${OUTPUT_PREFIX}"_orfs

  "${fraggenescanplus}" \
  -s "${INPUT_FNA}" \
  -o "${ORFS_OUT}" \
  -w 0 \
  -r "${FGSP_TRAIN_DIR}" \
  -t illumina_5 \
  -m 4096 \
  -p "${NSLOTS}" 2>&1 | handleoutput

  if [[ $? != 0 ]]; then
    echo "FragGeneScanPlus failed"
    exit 1
  fi

  INPUT_ORFS="${ORFS_OUT}".faa

   if [[ ! -f "${INPUT_ORFS}" ]]; then
    echo "FragGeneScanPlus failed"
    exit 1
  fi

fi

###############################################################################
# 10. Run UProC
###############################################################################

echo "Annotating SCGs ..." 2>&1 | handleoutput

UOUT="${THIS_JOB_TMP_DIR}/${OUTPUT_PREFIX}"_uout.csv

"${uproc_prot}" \
  --threads "${NSLOTS}" \
  --output "${UOUT}" \
  --preds \
  --pthresh 3 \
  "${SINGLE_COPY_COGS_DB}" \
  "${MODEL}" \
  "${INPUT_ORFS}" 2>&1 | handleoutput

if [[ $? != 0 ]]; then
  echo "uproc_prot failed"
  exit 1
fi

if [[ ! -f "${UOUT}" ]]; then
  echo "uproc_prot failed"
  exit 1
fi

###############################################################################
# 11. Format output
###############################################################################

COUNTS="${THIS_JOB_TMP_DIR}/${OUTPUT_PREFIX}"_single_cogs_count.tsv

cut -f1,3,4,5 -d"," "${UOUT}" | \
awk 'BEGIN {OFS="\t"; FS=","} {

  if (array_score[$1]) {

    if ($4 > array_score[$1]) {
      array_score[$1] = $4
      array_line[$1, $3] = $2
    }

  } else {

   array_score[$1] = $4
   array_line[$1, $3] = $2

  }

} END {

  printf "%s\t%s\n", "cog","cov"

  for (combined in array_line) {
    split(combined, separate, SUBSEP)
    array_length[separate[2]]= array_length[separate[2]] + array_line[combined]
  }

  for ( c in array_length ) {
    printf "%s\t%s\n", c,array_length[c]
  }

}' > "${COUNTS}"

if [[ $? != 0 ]]; then
  echo "formatting to *_counts,tsv failed (prot annotation)"
  exit 1
fi

###############################################################################
# 12. Compute AGS and NGs
###############################################################################
(
"${r_interpreter}" --slave --vanilla <<RSCRIPT

  # load data
  COGS_TBL <- read.table(file = "${COUNTS}",
                         header = T,  sep = "\t",
                         row.names = 1)

  COG_LENGTHS <- read.table(file = "${COG_LENGTHS}",
                            header = T,  sep = "\t",
                            row.names = 1)
  SAMPLE <- "${SAMPLE}"
  BP_TOTAL <- as.numeric("${BP_TOTAL}")

  # format tables
  i <- rownames(COG_LENGTHS)

  if (sum(!rownames(COG_LENGTHS) %in% rownames(COGS_TBL) ) > 0 ) {
    j <- !rownames(COG_LENGTHS) %in% rownames(COGS_TBL)
    missing <- rownames(COG_LENGTHS)[j]
    cov <- rep(0,length(missing))
    COGS_TBL[missing,] <- cov
  }

  # compute AGS
  x <- COGS_TBL[i,"cov"]/COG_LENGTHS\$value
  cov_mean <- mean(x)
  COMPUT_AGS <- round((BP_TOTAL)/cov_mean, digits = 3)
  COMPUT_NG <- round(cov_mean, digits = 3)

  OUTPUT <- data.frame(Sample = SAMPLE, AGS = COMPUT_AGS, NGs = COMPUT_NG, BPs = BP_TOTAL)

  write.table(file = "${THIS_JOB_TMP_DIR}/${OUTPUT_PREFIX}_ags.tsv", x = OUTPUT, quote = F,
              row.names = F, col.names = T, sep = "\t")

RSCRIPT

) 2>&1 | handleoutput

if [[ $? != 0 ]]; then
  echo "r code average genome size computation failed"
  exit 1
fi

if [[ ! -f ${THIS_JOB_TMP_DIR}/${OUTPUT_PREFIX}_ags.tsv ]]; then
  echo "r code average genome size computation failed"
  exit 1
fi

###############################################################################
# 13. Clean up
###############################################################################

if [[ "${SAVE_COMPLEMENTARY_DATA}" =~ [F|f] ]]; then

  rm "${COUNTS}"
  rm "${UOUT}"

  if [[ -n "${BBDUKFILTER}" && -f "${INPUT_FNA}" ]]; then
    rm "${INPUT_FNA}"
  fi

fi

###############################################################################
# 14. Move output for export
###############################################################################

rsync -a --delete "${THIS_JOB_TMP_DIR}" "${OUTDIR_LOCAL}"
