#!/bin/sh
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# set -x
# Set env variables for tagging text files/output
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS="$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _TAG_REDIR_IN=txt
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_OUT=txt

#
# Description:
# Hello script
#
# For additional usage information use "--help" flag as input to script.
#
# Example to run script:
# ./greetings.sh --firstname=Jane --lastname=Doe
#
# **************************************************************************************************#
# Print usage
printUsage() {
  echo "Usage: $(basename "$0"): " >&2
  echo "  * --install_dir=* (short '-idir=*') - zpm installtion directory to be sourced" >&2
  echo "    --state_dir=* (short '-sdir=*') - zpm state directory to be sourced, default '{install_dir}/state'" >&2
  echo "    --source_in_reverse (short '-sir') - source installed zpm products based on 'zpm list' table in reverse order, default 'false'" >&2
  echo "    --source_top_and_bottom (short '-stab') - source installed zpm products based on 'zpm list' first from the top then the bottom of the table, default 'false'" >&2
  echo "          --go_ver=* Directory where Golang is installed" >&2
  echo "	        --java_ver=* Directory where Java is installed" >&2
  echo "          --node_ver=* Directory where Node is installed" >&2
  echo "          --oelcpp_ver=* location where clang/clang++ is installed" >&2
  echo "          --python_ver=* Directory where python is installed" >&2
  echo "          --zoau_ver=* Directory where zoau is installed" >&2

}

# Langauge directory names
go=golang
java=java
nodejs=node
oelcpp=oelcpp
python=python
zoau=zoau

# Flags for testing specific installed version
go_test=0
java_test=0
nodejs_test=0
oelcpp_test=0
python_test=0
zoau_test=0


# Parse command line
parseCommandLine() {
    for i in "$@"; do
        case $i in
            --install_dir=*|-idir=*)
      			    install_dir=${i#*=}
              # Check last Character
              last_char=$(expr substr "$install_dir" "${#install_dir}" 1)
              if [ "$last_char" = "/" ]; then
                install_dir="${install_dir%?}"
              fi
        ;;
            --state_dir=*|-sdir=*)
                state_dir=${i#*=}
        ;;
            --source_in_reverse|-sir)
                source_in_reverse_order=true
		    ;;
            --source_top_and_bottom|-stab)
                source_top_and_bottom=true
		    ;;
            --go_ver=*|-gv=*)
             val=${i#*=}
             if [ -n "$val" ]; then
                _GO_VER=$val
                _GO_DIR=$go/${_GO_VER} # $(cd "${_GO_DIR}" && pwd)
                go_test=1
             fi
		    ;;
	          --java_ver=*|-jv=*)
             val=${i#*=}
             if [ -n "$val" ]; then
              _JAVA_VER=$val
	            _JAVA_DIR=$java/${_JAVA_VER} # $(cd "${_JAVA_DIR}" && pwd)
              java_test=1
            fi
		    ;;
            --node_ver=*|-nv=*)
            val=${i#*=}
             if [ -n "$val" ]; then
                _NODEJS_VER=$val
                _NODEJS_DIR=$nodejs/${_NODEJS_VER} # $(cd "${_NODEJS_DIR}" && pwd)
                nodejs_test=1
             fi
		    ;;
            --oelcpp_ver=*|-ocv=*)
             val=${i#*=}
             if [ -n "$val" ]; then
                _OELCPP_VER=$val
                _OELCPP_DIR=$oelcpp/${_OELCPP_VER} # $(cd "${XL_OELCPP_DIR}" && pwd)
                oelcpp_test=1
             fi
		    ;;
            --python_ver=*|-pv=*)
              val=${i#*=}
              if [ -n "$val" ]; then
                _PYTHON_VER=$val
                _PYTHON_DIR=$python/${_PYTHON_VER} # $(cd "${_PYTHON_DIR}" && pwd)
                python_test=1
              fi
        ;;
            --zoau_ver=*|-zv=*)
              val=${i#*=}
              if [ -n "$val" ]; then
                _ZOAU_VER=$val
                _ZOAU_DIR=$zoau/${_ZOAU_VER} # $(cd "${_ZOAU_DIR}" && pwd)
                zoau_test=1
              fi
        ;;
            -debug)
                set -x
		    ;;
            --help)
                printUsage;
                exit 0;
        ;;
            *)
                echo "Unrecognized option: $i"
                printUsage;
                exit 1;
                ;;
        esac
    done
}

# Main function to run script
main() {

  #Parse command line
  parseCommandLine "$@"

  # Verify required parameters
	if [ -z "$install_dir" ]; then
	  	echo "Not all required parameters provided. Please check usage below and re-run script with all required parameters:" >&2
		printUsage
		exit 4
	fi

	# Check if state directory is not provided and set relative to install dir
	if [ -z "$state_dir" ]; then
		state_dir=${install_dir}/state
	fi

  echo "Setting environment variables for ZPM installation directory ($install_dir) and state directory($state_dir)"

  #set environment variables for ZPM
  export PATH="$install_dir/package-manager/bin:$PATH"
  export ZPM_STATE_DIRECTORY="$state_dir"

  # Check the exit code
  if zpm config set Products_dir "$install_dir"; then
    echo "Sourcing zpm for '$install_dir' ..."
    echo ""
    # Check if product list is NOT being sorted in reverse order from ZPM List
    if [ "$source_in_reverse_order" != true ]; then
      # Source product list from top to bottom of zpm list
      source_product_envs "$(zpm list > ~/zpm.list  && chtag -r ~/zpm.list && cat ~/zpm.list | tail +3 | awk -v srcf="/.env" '{ print $3"" srcf ""}')"
    fi

    # Check if product list being sourced in reverse order or both top and bottom
    if [ "$source_in_reverse_order" = true ] || [ "$source_top_and_bottom" = true ]; then

      # Source product list from bottom to top of ZPM list
      source_product_envs "$(zpm list > ~/zpm.list  && chtag -r ~/zpm.list && cat ~/zpm.list | tail +3  |  awk -v srcf="/.env" '{a[i++]=$3} END {for (j=i-1; j>=0;) print a[j--]"" srcf ""}')"

      # Check if also if need to source from top of list
      if [ "$source_top_and_bottom" = true ]; then
        
        # Source product list from top to bottom of zpm list
        source_product_envs "$(zpm list > ~/zpm.list  && chtag -r ~/zpm.list && cat ~/zpm.list | tail +3 | awk -v srcf="/.env" '{ print $3"" srcf ""}')"
      fi
    fi
  else
    echo "ZPM not installed in $install_dir"

  fi

}

# Verify of product version should be sourced
shouldSourceProductVer() {
  # Flag to determine if ZPM installed product should be sourced
  shouldSourceDir=0

  # Set the input string
  input="$1"

  # Test if the input string starts with the "INSTALL_DIR"
  # if [ "${input#$install_dir}" != "$input" ]; then
  if expr "$input" : "^$install_dir" > /dev/null; then
  # if [ "$input" == "$install_dir"* ]; then

    # Strip off ".env" from the input string capturing everthin upto ".env"
    # input="${input%.env}"
    input=$(expr "$input" : '\(.*\)\.env$')

    if [ "$go_test" = "1" ] && echo "$input" | grep -q "/$go/"; then
    # if [ "${go_test}" == "1" && $input == *"/$go/"* ]; then
      # Check if go version was supplied and should be tested againts install go
      if echo "$input" | grep -q "$_GO_DIR"; then
      # if [ $input == *"$_GO_DIR"* ]; then
        echo " Found '$go' and '$_GO_VER' to source .env"
      else
        echo " Not Found '$go' and '$_GO_VER' to source .env"
        # Set flag to '1' false so this version is skipped
        shouldSourceDir=1
      fi

      # clear go version
      unset "$_GO_DIR"
      unset "$_GO_VER"
      return $shouldSourceDir
    fi

    if [ "$java_test" = "1" ] && echo "$input" | grep -q "/$java/"; then
    # if [ "${java_test}" == "1"  && $input == *"/$java/"* ]; then
      # Check if java version was supplied and should be tested againts install java
      if echo "$input" | grep -q "$_JAVA_DIR"; then
      # if [ $input == *"$_JAVA_DIR"* ]; then
        echo " Found '$java' and '$_JAVA_VER' to source .env"
      else
        echo " Not Found '$java' and '$_JAVA_VER' to source .env"
        # Set flag to '1' false so this version is skipped
        shouldSourceDir=1
      fi

      # clear java version
      unset "$_JAVA_DIR"
      unset "$_JAVA_VER"
      return $shouldSourceDir
    fi

    if [ "$nodejs_test" = "1" ] && echo "$input" | grep -q "/$nodejs/"; then
    # if [ "${nodejs_test}" == "1"  && $input == *"/$nodejs/"* ]; then
      # Check if nodejs version was supplied and should be tested againts install nodejs
      if echo "$input" | grep -q "$_NODEJS_DIR"; then
      # if [ $input == *"$_NODEJS_DIR"* ]; then
        echo " Found '$nodejs' and '$_NODEJS_VER' to source .env"
      else
        echo " Not Found '$nodejs' and '$_NODEJS_VER' to source .env"
        # Set flag to '1' false so this version is skipped
        shouldSourceDir=1
      fi

      # clear nodejs version
      unset "$_NODEJS_DIR"
      unset "$_NODEJS_VER"
      return $shouldSourceDir
    fi

    if [ "$oelcpp_test" = "1" ] && echo "$input" | grep -q "/$oelcpp/"; then
    # if [ "${oelcpp_test}" == "1"  && $input == *"/$oelcpp/"* ]; then
      # Check if oelcpp version was supplied and should be tested againts install oelcpp
      if echo "$input" | grep -q "$_OELCPP_DIR"; then
      # if [ $input == *"$_OELCPP_DIR"* ]; then
        echo " Found '$oelcpp' and '$_OELCPP_VER' to source .env"
      else
        echo " Not Found '$oelcpp' and '$_OELCPP_VER' to source .env"
        # Set flag to '1' false so this version is skipped
        shouldSourceDir=1
      fi

      # clear oelcpp version
      unset "$_OELCPP_DIR"
      unset "$_OELCPP_VER"
      return $shouldSourceDir
    fi

    if [ "$python_test" = "1" ] && echo "$input" | grep -q "/$python/"; then
    # if [ "${python_test}" == "1"  && $input == *"/$python/"* ]; then
      # Check if python version was supplied and should be tested againts install python
      if echo "$input" | grep -q "$_PYTHON_DIR"; then
      # if [ $input == *"$_PYTHON_DIR"* ]; then
        echo " Found '$python' and '$_PYTHON_VER' to source .env"
      else
        echo " Not Found '$python' and '$_PYTHON_VER' to source .env"
        # Set flag to '1' false so this version is skipped
        shouldSourceDir=1
      fi

      # clear python version
      unset "$_PYTHON_DIR"
      unset "$_PYTHON_VER"
      return $shouldSourceDir
    fi

    if [ "$zoau_test" = "1" ] && echo "$input" | grep -q "/$zoau/"; then
    # if [ "${zoau_test}" == "1"  && $input == *"/$zoau/"* ]; then
      # Check if zoau version was supplied and should be tested againts install zoau
      if echo "$input" | grep -q "$_ZOAU_DIR"; then
      # if [ $input == *"$_ZOAU_DIR"* ]; then
        echo " Found '$zoau' and '$_ZOAU_VER' to source .env"
      else
        echo " Not Found '$zoau' and '$_ZOAU_VER' to source .env"
        # Set flag to '1' false so this version is skipped
        shouldSourceDir=1
      fi

      # clear zoau version
      unset "$_ZOAU_DIR"
      unset "$_ZOAU_VER"
      return $shouldSourceDir
    fi
  fi
  echo
  return $shouldSourceDir

}

# Helper functions
source_product_envs() {
    #set out to input parameters of this function
    out=$*

    # Remove leading and trailing single quotes
    out=$(echo "$out" | sed "s/^'//; s/'$//")

    # Replace newline with space to separate the paths
    out=$(echo "$out" | tr '\n' ' ')

    echo "All product directories to be sourced:\n$out"

    set -a # -a Mark variables which are modified or created for export. and view changes to env variables
    while [ -n "$out" ] #while out not empty
    do
 
      # #Get the leading edge directory name
      # sourcethis="${out%% *}"
      # sourcethis="${sourcethis#\'}"
      # Get the leading edge directory name
      sourcethis=$(echo "$out" | awk '{print $1}')

      if shouldSourceProductVer "$sourcethis"; then
        echo "Source this: $sourcethis"
        # Source zpm product .env file
        # shellcheck source=/dev/null
        . "$sourcethis"
      else
        echo "Skipped sourcing this '$sourcethis'"
      fi

      #Set the out to remaining directories
      # out=$(echo ${out#*[:space:]})
      # out="${out#* }"
      # Set the remaining directories in 'out'
      out=$(echo "$out" | awk '{$1=""; print $0}' | awk '{$1=$1};1')

      # Check if 'out' still contains spaces
      # if [ "$out" != "${out/ /}" ]; 
      if expr "$out" : '.* .*' > /dev/null; 
       then {
        # Echo blank line
        echo
        echo "Continue with more directories to source..."
       } else {

        if shouldSourceProductVer "$out"; then
          echo "Source last directory: $out"
          # Source last zpm product .env file
          # shellcheck source=/dev/null
          . "$out"
        else
          echo "Skipped sourcing this '$out'"
        fi

         #Set out to emppty string
         out=""

         #break out of while loop
         break;
       }
      fi
    done
    set +a
}

# Defaults
source_in_reverse_order=false
source_top_and_bottom=false
state_dir=

# Run script main
main "$@"
