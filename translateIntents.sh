#!/bin/bash
# input:
# services_cpu
# services_memory
# output:
# translated_services_cpu
# translated_services_memory

# Define mappings
declare -A CPU_MAPPING=(
  [light]=0.5
  [small]=1
  [medium]=4
  [large]=8
)

declare -A MEMORY_MAPPING=(
  [light]="500Mi"
  [small]="1Gi"
  [medium]="2Gi"
  [large]="8Gi"
)

declare -A STORAGE_MAPPING=(
  [small]="10GB"
  [medium]="20GB"
  [large]="40GB"
)

# CPU translation
translate_cpu() {
  local input=$1
  if [[ -n "${CPU_MAPPING[$input]}" ]]; then
    echo "${CPU_MAPPING[$input]}"
  else
    echo "$input"
  fi
}

# Memory translation
translate_memory() {
  local input=$1
  if [[ -n "${MEMORY_MAPPING[$input]}" ]]; then
    echo "${MEMORY_MAPPING[$input]}"
  else
    echo "$input"
  fi
}

# Storage translation
translate_storage() {
  local input=$1
  if [[ -n "${STORAGE_MAPPING[$input]}" ]]; then
    echo "${STORAGE_MAPPING[$input]}"
  else
    echo "$input"
  fi
}

# Example usage
# translate_cpu 2
# translate_cpu medium
# translate_memory 1Gi

translated_services_cpu=()
for val in "${services_cpu[@]}"; do
  translated_services_cpu+=( "$(translate_cpu "$val")" )
done

translated_services_memory=()
for val in "${services_memory[@]}"; do
  translated_services_memory+=( "$(translate_memory "$val")" )
done
