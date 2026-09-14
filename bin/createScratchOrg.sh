#!/bin/bash

##############################################################################
#
# Usage: setupScratchOrg [-a <scratch alias>] [--alias <scratch alias>]
#                        [-d <duration in days>] [--duration <duration in days>]
#                        [-f <config file path>] [--config-file <config file path>]
#                        [-c] [--clean]          
#
##############################################################################

usage=$(cat <<EOF
Usage: setupScratchOrg [-a <scratch alias>] [--alias <scratch alias>]
                       [-d <duration in days>] [--duration <duration in days>]
                       [-f <config file path>] [--config-file <config file path>]
                       [-c] [--clean]
EOF
)

# Set variable defaults
alias='myScratchOrg'
duration='4'
clean_run=false
config_file_path='config/project-scratch-def.json'

# Get and validate inputs
while [[ $# -gt 0 ]]; do
    case "$1" in
        "-a" | "--alias")
            shift
            alias="$1"
            shift
            ;;
        "-d" | "--duration")
            shift
            duration="$1"
            shift
            ;;
        "-c" | "--clean")
            clean_run=true
            shift
            ;;
        "-f" | "--config-file")
            shift
            config_file_path="$1"
            shift
            ;;
        *)
            echo "${usage}"
            exit 0
            ;;
    esac
done

# Validate if Dev Hub exists
if [[ "$(sf org list --json | grep -c 'DevHub')" -eq 0 ]]
    then
        echo "***********************************************"
        echo "No DevHub found. Please connect to a DevHub"
        echo "***********************************************"
        exit 0
fi

# Validate if Scratch Org already exists
if [[ "$(sf org list --json | grep -c "${alias}")" -ne 0 ]]
    then
        scratch_org_found=true
    else
        scratch_org_found=false
fi

# If Scratch Org DOES exist, should it be replaced?
if [ "${scratch_org_found}" = true ]
    then
        if [ "${clean_run}" = true ]
            then
                # Delete Scratch Org with same alias
                echo "***********************************************"
                echo "Deleting Scratch Org"
                echo "***********************************************"
                sf org delete scratch --target-org "${alias}" --no-prompt
            else
                # If not a clean run, stop                
                echo "***********************************************"
                echo "Scratch Org '${alias}' Already Exists"
                echo "***********************************************"
                exit 1
        fi
fi

# Create Scratch Org from DevHub for Given Duration Days
echo "***********************************************"
echo "Creating new scratch org named: ${alias} and will be valid for ${duration} days"
echo "***********************************************"
sf org create scratch -a "${alias}" -y "${duration}" -f "${config_file_path}" --set-default

# Deploy all Metadata to Scratch Org
echo "***********************************************"
echo "Deploying Metadata to Scratch Org ${alias}"
echo "***********************************************"
sf project deploy start -d sfdx-source -o "${alias}" -c

# Assign Permission Set to User
echo "***********************************************"
echo "Assigning default Permission Set"
echo "***********************************************"
sf org assign permset -n BoardGamePS -o "${alias}"

# Populate Data Using Plan
echo "***********************************************"
echo "Populate Scratch Org using Import Plan"
echo "***********************************************"
sf data import tree -p ./data/Import-plan.json

echo "***********************************************"
echo "Scratch Org ${alias} Ready"
echo "***********************************************"
