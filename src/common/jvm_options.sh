#!/bin/bash -eu

# Reads a jvm options file and stores parameters in an ordered array.
# Parameters:
#   $1 - input file
#   $2 - name of the array reference to store results
read_jvm_options_file() {
    local file="$1"
    declare -n ref_array="$2"

    while IFS= read -r line; do
        # Skip empty lines or those starting with '#'
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        ref_array+=("$line")
    done < "$file"
}

# Updates parameters from another file, maintaining order.
# Parameters:
#   $1 - input file
#   $2 - name of the array reference to update
update_jvm_options_file() {
    local file="$1"
    # shellcheck disable=SC2178
    declare -n ref_array="$2"

    # Temporary map to track updated keys
    declare -A updated_keys

    # Read overrides from the file
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Extract key and value
        local key="${line%%=*}"

        # Track updated keys
        # shellcheck disable=SC2034
        updated_keys["$key"]="$line"

        # Update existing parameters in the array
        local found=false
        for i in "${!ref_array[@]}"; do
            if [[ "${ref_array[$i]}" == "$key"* ]]; then
                ref_array[i]="$line"
                found=true
                break
            fi
        done

        # If not found, add the new parameter
        if [[ "$found" == false ]]; then
            ref_array+=("$line")
        fi
    done < "$file"
}

# Adds a new parameter to the array. If the parameter already exists, it updates its value.
# Parameters:
#   $1 - full parameter string (e.g., "-Xmx4096m" or "-Dmy.property=value")
#   $2 - name of the array reference to modify
put_param() {
    local param="$1"
    # shellcheck disable=SC2178
    declare -n ref_array="$2"

    # Extract the key (part before '=') and value (part after '=')
    local key="${param%%=*}"

    # Check if the key already exists
    local found=false
    for i in "${!ref_array[@]}"; do
        if [[ "${ref_array[$i]}" == "$key"* ]]; then
            ref_array[i]="$param" # Update the existing parameter
            found=true
            break
        fi
    done

    # If not found, add it to the end of the array
    if [[ "$found" == false ]]; then
        ref_array+=("$param")
    fi
}

# Removes parameters from an array whose names start with a given prefix.
# Parameters:
#   $1 - prefix to match
#   $2 - name of the array reference to modify
remove_params_with_prefix() {
    local prefix="$1"
    # shellcheck disable=SC2178
    declare -n ref_array="$2"

    for i in "${!ref_array[@]}"; do
        if [[ "${ref_array[$i]}" == "$prefix"* ]]; then
            unset 'ref_array[i]'
        fi
    done

    # Re-index array to maintain proper order
    ref_array=("${ref_array[@]}")
}

# Builds the final parameter list for 'java' from the array.
# Parameters:
#   $1 - name of the array reference
#   $2 - name of the variable reference to store the output string of parameters
build_java_params() {
    # shellcheck disable=SC2178
    declare -n ref_array="$1"
    declare -n ref_result="$2"

    ref_result=$(printf " %s" "${ref_array[@]}")
    ref_result="${ref_result:1}" # Remove leading space
}

## Test it: `. jvm_options.sh; test_jvm_options`
test_jvm_options() {
  assert() {
      local name="$1"
      local actual="$2"
      local expected="$3"
      if [[ "$actual" != "$expected" ]]; then
          echo "Assertion '$name' failed!" >&2
          echo "Expected: '$expected'"
          echo "Got:      '$actual'"
      else
          echo "Assertion '$name' success!" >&1
      fi
  }
  mkdir -p "$HOME/.temp"
  local main_file="$HOME/.temp/main.jvm_options"
  local override_file="$HOME/.temp/override.jvm_options"

  echo -e "-Xmx123M\n-Xms123M\n-Dmy.param=old_value\n" > "$main_file"
  echo -e "-Dmy.param=new_value\n-Dmy.param2=new_value2\n" > "$override_file"

  # shellcheck disable=SC2034
  declare -a opts
  read_jvm_options_file "$main_file" opts
  update_jvm_options_file "$override_file" opts

  remove_params_with_prefix "-Xm" opts
  put_param "-Xms456M" opts
  put_param "-Xmx456M" opts

  # shellcheck disable=SC2034
  declare jvm_params
  build_java_params opts jvm_params
  assert "jvm_params" "$jvm_params" "-Dmy.param=new_value -Dmy.param2=new_value2 -Xms456M -Xmx456M"
}

