#!/bin/bash

input_file=$1
output_file=$2

awk '
{
    for (i = 1; i <= NF; i++) {
        if (NR == 1) {
            data[i] = $i
        } else {
            data[i] = data[i] " " $i
        }
    }
}
END {
    for (i = 1; i <= NF; i++) {
        print data[i]
    }
}
' "$input_file" > "$output_file"
