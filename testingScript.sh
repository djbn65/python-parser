# This script assumes that all test files are in a folder called testFiles
# and all results are output to files of the same name with .out extension
# appended in a folder called output

make

for file in testFiles/*; do
  echo ${file##*/}
  echo
  ./parser ${file}
  echo
done