#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
ORANGE='\033[1;33m'
WHITE='\033[1;37m'

echo -e "\n${RED}NOTE : This script should be executed only if there are any errors before RPM installation during patching."

TakeUserConsent() {
    echo -e "\n${ORANGE}Are you sure to clean up the VC failed patch bits ? Press (Y/N) to continue"
    while read -r -n 1 -s userInput; do
    if [[ $userInput = [YyNn] ]]; then
        [[ $userInput = [Yy] ]] && retval=0
        [[ $userInput = [Nn] ]] && retval=1
        break
    fi
    done
    return $retval
}

vCenterCleanup() {
    if TakeUserConsent; then
        echo -e "\n${ORANGE}Cleaning up the failed patch bits."
        if [ -f /etc/applmgmt/appliance/software_update_state.conf ]; then
            mv /etc/applmgmt/appliance/software_update_state.conf /var/tmp/software_update_state.conf_backup
        fi
        if [ -f /storage/db/patching.db ]; then
            mv /storage/db/patching.db /storage/db/patching.db.cleanup
        fi
        if [ -f /storage/core/software-update/stage/stageDir.json ]; then
            stageDir=`grep 'StageDir' /storage/core/software-update/stage/stageDir.json | sed -r 's/^[^:]*:(.*)$/\1/'`
            rm -rf $stageDir
        fi
        if [ -f /var/vmware/applmgmt/fileintegrity/fileintegrity_config.sig ]; then
            mv /var/vmware/applmgmt/fileintegrity/fileintegrity_config.sig /var/vmware/applmgmt/fileintegrity/fileintegrity_config.sig.bkp
        fi
        rm -rf /storage/core/software-update/*
        echo -e "\n${GREEN}VC failed patch bits cleaned up successfully."
    else
        echo -e "\n${YELLOW}VC failed patch bits Cleanup skipped by user."
    fi
}

vCenterCleanup