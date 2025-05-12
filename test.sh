#!/bin/bash

boxvertical="0.58"
boxhorizontal="0.98"

# Regex for a number: optional digits, optional decimal part
number_regex='^[0-9]+(\.[0-9]+)?$'

if [[ "$boxvertical" =~ $number_regex ]] && [[ "$boxhorizontal" =~ $number_regex ]]; then
  echo "set key at graph ${boxvertical}, ${boxhorizontal}" 
else
  echo "set key $boxvertical $boxhorizontal"
fi

