#! /bin/bash -

help_and_exit() {
  cat <<-EOF
  Usage: scregcp [-h|-s|-c] [<screenshots_base_folder>]

  Take screenshot of a whole screen or a specified region,
  save it to a specified folder (current folder is default)
  and copy it to a clipboard.

    -h   - print help and exit
    -s   - take a screenshot of a screen region
    -c   - save only to clipboard
EOF
    exit 0
}

base_folder="./"
savefile=true
region=false
params="-window root"
while test $# -gt 0; do
  case "$1" in
    -h|--help*)
      help_and_exit
      ;;
    -r|--region*)
      params=""
      shift
      ;;
    -c|--clipboard-only*)
      savefile=false
      shift
      ;;
    *)
      if [[ $1 =~ ^\- ]] ; then
        echo "error: unknown flag '$1'"
        help_and_exit
      fi
      echo "Setting base folder to ${1}"
      base_folder="${1}/"
      shift
      ;;
  esac
done

file_path=${base_folder}$( date '+%Y-%m-%d_%H-%M-%S' )_screenshot.png
import ${params} ${file_path}
xclip -selection clipboard -target image/png -i < ${file_path}
echo "Wrote to $file_path"

if [ "$savefile" = false ] ; then
  rm ${file_path}
fi
