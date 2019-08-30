#!/bin/bash
search_dir=stdlog/$1
rm -rf makegraph.csv
for filename in "$search_dir"/*
do
    base_filename="$(basename -- $filename)"
    echo "$base_filename" >> makegraph.csv
    cat "$filename" | awk '/Sim Running/{print $1" " $5}' >> makegraph.csv

done 
