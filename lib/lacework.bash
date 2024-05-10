#!/bin/bash

set -euo pipefail

PLUGIN_PREFIX="LACEWORK"
# Reads a single value
function plugin_read_config() {
  local var="BUILDKITE_PLUGIN_${PLUGIN_PREFIX}_${1}"
  local default="${2:-}"
  echo "${!var:-$default}"
}


function configure_plugin() {

    # required options
    export ACCOUNT_NAME="$(plugin_read_config ACCOUNT_NAME)"

    if [ -z "${ACCOUNT_NAME}" ]; then
        echo "ERROR: Missing required config 'account-name'" >&2
        exit 1
    fi

    export SCAN_TYPE="$(plugin_read_config SCAN_TYPE)"

    if [ -z "${SCAN_TYPE}" ]; then
        echo "ERROR: Missing required config 'scan-type'" >&2
        exit 1
    fi

    export API_KEY_ENV_VAR="$(plugin_read_config API_KEY_ENV_VAR LW_API_KEY)"

    export API_KEY_SECRET_ENV_VAR="$(plugin_read_config API_KEY_SECRET_ENV_VAR LW_API_SECRET)"

    export PROFILE="$(plugin_read_config PROFILE '')" 

    export ACCESS_TOKEN_ENV_VAR="$(plugin_read_config ACCESS_TOKEN_ENV_VAR LW_API_TOKEN)"

    export VULNERABILITY_SCAN_REPOSITORY="$(plugin_read_config VULNERABILITY_SCAN_REPOSITORY '')"

    export VULNERABILITY_SCAN_TAG="$(plugin_read_config VULNERABILITY_SCAN_TAG '')"

    #put other options from plugin.yml here
    


}

# Lacework Scans based on the provided scan tool
function lacework_scan() {
    case "${SCAN_TYPE}" in
        sca)
        lacework_sca
        ;;

        iac)
        lacework_iac
        ;;

        vulnerability)
        lacework_vulnerability
        ;;

        sast)
        lacework_sast
        ;;
    esac
}


function lacework_sca() {

    echo "--- Running Lacework SCA scan"

    CMD=(
    lacework
    )

    if [ -n "$PROFILE" ]; then
    CMD+=(
        --profile "$PROFILE"
    )
    fi  

    CMD+=(
        --account "${ACCOUNT_NAME}"
        --api_key "${API_KEY_ENV_VAR}"
        --api_secret "${API_KEY_SECRET_ENV_VAR}"
    )

    CMD+=(
        sca scan .
        --save-results
    )
        

    echo "${CMD[@]}"

    "${CMD[@]}" 
}

function lacework_iac() {

    echo "--- Running Lacework IAC scan"

    CMD=(
    lacework
    )

    if [ -n "$PROFILE" ]; then
    CMD+=(
        --profile "$PROFILE"
    )
    fi  

    CMD+=(
        --account "${ACCOUNT_NAME}"
        --api_key "${API_KEY_ENV_VAR}"
        --api_secret "${API_KEY_SECRET_ENV_VAR}"
        iac
        "${IAC_SCAN_TYPE}"
    )


    echo "${CMD[@]}"

    "${CMD[@]}" .
}

function lacework_vulnerability() {

    echo "--- Running Lacework Container Vulnerability scan"

    CMD=(
    lacework
    )

    if [ -n "$PROFILE" ]; then
    CMD+=(
        --profile "$PROFILE"
    )
    fi  

    CMD+=(
        --account-name "${ACCOUNT_NAME}"
        --access-token "${ACCESS_TOKEN_ENV_VAR}"
    )

    CMD+=(
        vuln-scanner image evaluate
        "${VULNERABILITY_SCAN_REPOSITORY}"
        "${VULNERABILITY_SCAN_TAG}"
    )

    
    echo "${CMD[@]}"

    "${CMD[@]}"
}
