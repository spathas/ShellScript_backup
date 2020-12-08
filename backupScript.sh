#!/bin/bash
echo
echo
echo "IMPORTANT!!! RUN SCRIPT WITH SUDO COMMAND"
echo "IMPORTANT!!! ALL DIRECTORIES HAVE TO CLOSE WITH / AT THE END"
echo
echo
echo

#Variables
BACKUP_DIR="/var/backups"
BACKUP_NAME="backup"
BACKUP_DATE=`date +"%m-%d-%y"`
BACKUP_FILES="/home/${HOSTNAME}/"
BACKUP_IGNORE=""
#Controllers
chooseFileCompleted="n"


######################################--FUNCTIONS--##########################################
function changeFileName {
    echo -n "Enter another name:  "
    local changeName='backup;'
    read changeName
    
    BACKUP_NAME=$changeName
    
    echo "Name change to \"$BACKUP_NAME\"_$BACKUP_DATE".
}

#Create a new folder if does not exist
function createFolder {
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir $BACKUP_DIR
  fi
}

#Change the directory where backups would save in.
function changeDir {
    local changeDir='backup'
    echo -n "Current path is \"$BACKUP_DIR\" enter another path:  "
    read changeDir
    echo "$changeDir"
    BACKUP_DIR=$changeDir
    echo "Direction change to \"$changeDir\""
}

#Manage ingored files
function setExcludeFiles {
    local folder=""
    local ignore=""
    echo -n "Choose the directory you want to backup: "
    read folder
    echo
    echo "Choose the file or folder you want to ignore(NOT FULL PATH ONLY THE NAME OF FILE except nested files): "
    read ignore
    echo
    BACKUP_FILES="$folder"
    BACKUP_IGNORE=' --exclude='$folder$ignore''
    while [ "$count" != "-1" ]
    do
    echo -n "Would you like to remove more files from you list? Y/n: "
    count="n"
    read count
        if [[ "$count" == "Y" || "$count" == "y" ]]
        then
            echo -n "Choose the file or folder you want to ignore: "
            read ignore
            echo 
            BACKUP_IGNORE+=' --exclude='$folder$ignore''
        fi
        if [[ "$count" == "n" || "$count" == "N" ]]
            then
                count="-1"
        fi
    done
}

#Selector to setting up the backup command.
function chooseFilesToBackup {
    echo "Choose file you want to backup, by default the program will backup the home folder by user."
    #########################################Controllers###########################################
    countFileBackup="0"
    one="true"
    two="true"
    three="true"
    
    while [ "$countFileBackup" != "-1" ]
    do
    
        ################################## Messages ##########################################
        echo
        echo "Choose a number to make your change: "
        if [[ "$one" == "true" ]]
        then
            echo "1. Choose a folder or files to take a backup."
        else
            echo "1. You already setup this stage, but you can change that again."
        fi
        if [[ "$two" == "true" ]]
        then
            echo "2. Choose files to remove from backup."
        else
            echo "2. You already setup this stage, but you can change that again."
        fi
        if [[ "$three" == "true" ]]
        then
            echo "3. Choose another directory to save your backup."
        else
            echo "3. You already setup this stage, but you can change that again."
        fi
        echo -n "If you want to continue without changes press \"Enter\": "
        read count
        
        ################################## Function ##########################################
        case $count in
        
        1)
            echo "Choose a folder to backup. You can choose more than one folder with a space between directories."
            echo -n "Enter directory/ies: "
            local reader
            read reader 
            BACKUP_FILES="$reader"
            one="false"
            ;;
        2)
            setExcludeFiles
            one="false"
            two="false"
            ;;
        3)
            changeDir
            three="false"
            ;;
        *)
            echo "Set up of archive is finished..."
            countFileBackup=-1
            ;;
        esac
        
        ############################Exit after seting up all steps############################
        if [ "$one" == "false" ] && [ "$two" == "false" ] && [ "$three" == "false" ]
        then
            echo
            echo
            echo "Setup finished..."
            countFileBackup=-1
        fi
        
    done
    
    chooseFileCompleted="y"
    
}

#Crete the script which generate auto Backups.
function createAutoBackup() {
    local cronBackup=/etc/cron.$1/backup
    echo "$cronBackup"
    echo "#!/bin/bash" > $cronBackup
    echo "tar $BACKUP_IGNORE -czvf ${BACKUP_DIR}${BACKUP_NAME}_\`date +\"%m-%d-%y\"\`.tgz $BACKUP_FILES" >> $cronBackup
    sudo chmod 777 /etc/cron.$1/backup
    createFolder
}

#Selector for backup access time.
function setAutoBackup {
    echo "You can set up your backup automatically. Choose whenever you want it to take place your backup."
    count="0"
    while [ "$count" != "-1" ]
    do
        echo -n "You can choose hourly, daily, weekly, monthly: "
        local autoBackupCount
        read autoBackupCount
        
        case $autoBackupCount in
        
            "hourly")
                createFolder
                createAutoBackup "hourly"
                count="-1"
                ;;
            "daily")
                createFolder
                createAutoBackup "daily"
                count="-1"
                ;;
            "weekly")
                createFolder
                createAutoBackup "weekly"
                count="-1"
                ;;
            "monthly")
                createFolder
                createAutoBackup "monthly"
                count="-1"
                ;;
            *)
                echo "Enter one of 4 below keys."
                ;;
        esac
    done
}

######################################################--MAIN FLOW--#########################################################
#Setup auto backup per time.
echo -n "Would you like to setup the program to make automatically backups? Y/n: "
count="n"
read count

if [[ $count == "Y" || $count == "y" ]]
    then
    echo
    #########################################Controllers###########################################
    one="true"
    two="true"
    three="true"
    
    while [ "$menuCount" != "-1" ]
    do
    
        ################################## Messages ##########################################
        if [[ "$one" == "true" ]]
        then
            echo "1. The name of the file would look like this: ex. ${BACKUP_NAME}_${BACKUP_DATE}. Date values can't change!"
        else
            echo "1. You already setup this stage to $BACKUP_NAME, but you can change that again. Press C to exit."
        fi
            
        if [[ "$two" == "true" ]]
        then
            echo "2. Directory of backups is: ${BACKUP_DIR}."
        else
            echo "2. You already setup this stage to $BACKUP_DIR, but you can change that again. Press C to exit."
        fi
        
        if [[ "$three" == "true" ]]
        then
            echo "3. Set an autonomous backup for your system."
        else
            echo "3. You already setup this stage, but you can change that again. Press C to exit."
        fi
        
        echo -n "Choose a number to make your change: "
        read menuCount
        
        if [[ $count == "C" || $count == "c" ]]
        then
            count=c
        fi
        
        ################################## Function ##########################################
        case $menuCount in
            
            1)
                changeFileName
                one="false"
                ;;
            2)
                changeDir
                two="false"
                ;;
            3)
                chooseFilesToBackup
                setAutoBackup
                three="false"
                ;;
            c)
                menuCount=-1
                ;;
            C)
                menuCount=-1
                ;;
            *)
                echo "If you change you mind or finish you changes press \"C\" to leave."
                ;;
        esac
    
        if [ "$one" == "false" ] && [ "$two" == "false" ] && [ "$three" == "false" ]
        then
            echo
            echo
            echo "Setup finish..."
            menuCount=-1
        fi
        echo
    done
    
fi

#Take a instant backup.
echo -n "Would you like to take a backup right now? Y/n: "
count="n"
read count

if [[ "$count" == "Y" || "$count" == "y" ]]
then

    if [ "$chooseFileCompleted" == "n" ]
    then
        createFolder
        chooseFilesToBackup
    fi
    DATE=$(date +"%m-%d-%Y")
    sudo tar${BACKUP_IGNORE} -czvf $BACKUP_DIR$BACKUP_NAME-${DATE}.tar.gz --absolute-names $BACKUP_FILES
    echo "sudo tar${BACKUP_IGNORE} -czvf $BACKUP_DIR$BACKUP_NAME-${DATE}.tgz --absolute-names $BACKUP_FILES"
    echo 
    echo "You can find your backup file in path: $BACKUP_DIR."
fi

echo "Program finish..."
###############################################END#############################################
