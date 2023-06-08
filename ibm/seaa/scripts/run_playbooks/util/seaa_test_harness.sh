#!/bin/bash
# Source this script in another script that can be used as apart of a CI/CD pipeline, regressin bucket to run deployment scenarios

# failure_count
declare -i failure_count=0

# Declare failer log
failed_log_file=failure_output.log
# remove older failure log if it exist
if [ -f "$failed_log_file" ]; then
  rm $failed_log_file
fi

# Check to see if SEAA_TEST_SUITE ENV provided
if [[ -v SEAA_TEST_SUITE && ${#SEAA_TEST_SUITE[@]} -ne 0 ]]; then
  echo "Using environment variable for test suite array ..."
  # Read the array from the environment variable
  eval "declare -A a_test_case_suite=${SEAA_TEST_SUITE#*=}"
fi
# Check to see if test suite array is provided
if [[ -z "${test_case_suite[*]}" ]]; then
  echo "No test suite provided..."
  exit 99
fi

# test_count
declare -i test_count=${#test_case_suite[@]}

# number of test
declare -i run_count=0

# Format variables
red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;34m"
reset="\033[0m"


# Parse ansible output for any failed tasks
parse_ansible_output() {
  ansible_out="$1"

  # Check for ansible failed task
  if [[ "$ansible_out" =~ failed=[0-9]+ ]]; then
    failed_tasks=()
    while IFS='' read -r line; do failed_tasks+=("$line"); done < <(echo "$ansible_out" | grep -oE 'failed=[0-9]+' | grep -oE '[0-9]+')
    
    for failed_count in "${failed_tasks[@]}"; do
      if [ "$failed_count" -ne 0 ]; then
        seperator="################################################################## Failed ($2) ##################################################################\n"
        echo -e "$seperator $ansible_out" >> $failed_log_file
        return 1
      fi
    done
  # Check to see if any ansible task have run
  elif ! echo "$ansible_out" | grep -qE 'ok=[0-9]+'; then
    seperator="################################################################## Failed ($2) ##################################################################\n"
    echo -e "$seperator $ansible_out" >> $failed_log_file
    return 99
  fi
  return 0
}

# Sort testcase names
temp_keys=()
while IFS= read -r key; do temp_keys+=("$key"); done < <(for key in "${!test_case_suite[@]}"; do echo "$key"; done | sort)

# Run all testcases in testsuite
for test_case_name in "${temp_keys[@]}"; do
  run_count+=1
echo -e "${cyan}Running${reset} ${test_case_name} ${run_count} of ${test_count} ..."

  # Split the test case into arguments
  test_args=()
  while IFS='' read -r line; do test_args+=("$line"); done < <(echo "${test_case_suite[$test_case_name]}" | tr " " "\n")

  # Verify Ansible output
  if [[ "${verify_ansible_output:-true}" = true ]]; then

    if [[ "${show_terminal_during_run:-true}" = true ]]; then
        eval "${test_case_suite[$test_case_name]}" | tee -a output.log
        # Cat output.log into variable
        output="$(cat output.log)"
        # Delete output.log file
        rm output.log
    else
        #  Run the test case and store the output in a variable
        output=$(eval "${test_case_suite[$test_case_name]}" 2>&1)
    fi

    if ! parse_ansible_output "$output" "$test_case_name"; then

      if [[ "${show_terminal_during_run}" = true ]]; then
        echo -e "\t${red}FAILED${reset}: task in ${test_case_name} - with parms ${test_args[*]}}"
      else
        echo -e "\t${red}FAILED${reset}: task in ${test_case_name} - with parms ${test_args[*]}, review ${cyan}${failed_log_file}${reset} for details."
      fi

      failure_count+=1
      if [[ "${continue_on_failure:-true}" = false ]]; then
        break
      else
        continue
      fi
    else
      echo -e "\t${green}PASSED${reset}: ${test_case_name} - with parms '${test_args[*]}'"
    fi
  else
    echo "Verifying $test_case_name ran ..."
    # Run the test case
    eval "${test_case_suite[$test_case_name]}"
    rc=$?
    # Check the return code
    if [ $rc -ne 0 ]; then
        echo "$test_case_name failed with return code $rc"
        echo -e "\t${red}FAILED${reset}: ${test_case_name} -with parms '${test_args[*]} return code $rc'"
        if [[ "$continue_on_failure" = false ]]; then
            break
        else
            continue
        fi
    else
        echo -e "\t${green}PASSED${reset}: ${test_case_name} -with parms '${test_args[*]}'"
    fi
  fi
done

# Check it there any failed scripts and return
if [ "$failure_count" -gt 0 ]; then
    percentage=$(awk "BEGIN { printf \"%.2f\", ($failure_count/$test_count) * 100 }")
    echo -e "${red}$failure_count of $test_count ($percentage)% testcase failed.${reset}"
    exit 1
else
    echo -e "${green}All ($test_count) testcase ran successfully.${reset}"
    exit 0
fi
