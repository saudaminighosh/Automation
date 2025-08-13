#!/bin/bash
# Define the namespace where your pods are running
CURRENT_TIME=$(date +"%Y-%m-%d_%H-%M-%S")
# Directory where individual pod logs will be stored
LOG_DIR="./POD_LOGS"
mkdir -p "$LOG_DIR"
# Path where the cumulative log file will be stored with timestamp
#MASTER_LOG_PATH="$LOG_DIR/SMSF_logs_$CURRENT_TIME.log"
#echo "Pod Name Prefixes: $CONTAINER_NAME" >> "$MASTER_LOG_PATH"
#echo "==================================" >> "$MASTER_LOG_PATH"
#CURRENT_TIME=$(date +"%Y-%m-%d_%H-%M-%S")
File="$LOG_DIR/POD_INFO_$CURRENT_TIME.log"
echo "Enter the no. of different kinds of pod logs you want to take"
read num
for (( i=1; i <= $num; ++i ))
do
    echo "Please enter the namespace of the pods : "
    read NAMESPACE
    #echo "Namespace: $NAMESPACE" >> "$MASTER_LOG_PATH"
    comm=$(kubectl get pods -n $NAMESPACE > $File)
    echo "Do we need to provide container name ?(y/n)"
    read CONTAINER
    if [[ "$CONTAINER" = "y" ]]; then
        echo "Enter the container name of pod : "
        read CONTAINER_NAME
    fi
    echo "Enter the pod name(please don't enter the entire pod name, only provide the main name): "
    read POD_NAME
    echo "Do you want to use search pattern to grep (y/n): "
    read SEARCH
    if [[ "$SEARCH" = "y" ]]; then
        echo "Enter the search pattern to grep :"
        read SEARCH_PATTERN
    fi
    #CURRENT_TIME=$(date +"%Y-%m-%d_%H-%M-%S")
    # Directory where individual pod logs will be stored
    #LOG_DIR="./POD_LOGS"
    #mkdir -p "$LOG_DIR"
    # Path where the cumulative log file will be stored with timestamp
    #MASTER_LOG_PATH="$LOG_DIR/SMSF_logs_$CURRENT_TIME.log"
    #echo "Namespace: $NAMESPACE" >> "$MASTER_LOG_PATH"
    #if [[ "$CONTAINER"="y" ]]; then
        #echo "Pod Name Prefixes: $CONTAINER_NAME" >> "$MASTER_LOG_PATH"
    #fi
    #echo "Pod Name: $POD_NAME" >> "$MASTER_LOG_PATH"
    #if [[ "$SEARCH" = "y" ]]; then
        #echo "Search Pattern: $SEARCH_PATTERN" >> "$MASTER_LOG_PATH"
    #fi
    #echo "==================================" >> "$MASTER_LOG_PATH"
    echo "Going to take logs"
    #while IFS= read -r line; do
        #echo "Processing line: $line"
    #done < "$LOG_DIR/POD_INFO_$CURRENT_TIME.log"
    comm=$(touch $LOG_DIR/POD_LIST.log)
    comm=$(grep "$POD_NAME" $LOG_DIR/POD_INFO_$CURRENT_TIME.log > $LOG_DIR/POD_LIST.log)
    #echo "Pod name is : $POD_NAME"
    comm=$(awk '{print $1}' $LOG_DIR/POD_LIST.log > $LOG_DIR/output_${POD_NAME}_$CURRENT_TIME)
    while IFS= read -r line; do
        POD="$line"
        #echo "$line"
        comm=$(touch $LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log)
        #echo "$comm"
        MASTER_LOG_PATH="$LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log"
        #echo "$MASTER_LOG_PATH"
        echo "Namespace: $NAMESPACE" > "$LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log"
        echo "Pod Name: $POD_NAME" >> "$LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log"
        if [[ "$CONTAINER"="y" ]]; then
            echo "Pod Name Prefixes: $CONTAINER_NAME" >> "$LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log"
        fi
        echo "==================================" >> "$LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log"
        if [ "$CONTAINER" = "y" ] &&  [ "$SEARCH" = "y" ]; then
            echo "Option 1"
            comm=$(kubectl logs pod/${POD} -c $CONTAINER_NAME -n $NAMESPACE | grep -i $SEARCH_PATTERN >> $LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log)
        elif [ "$CONTAINER" = "y" ] && [ "$SEARCH" = "n" ]; then
            echo "Option 2"
            comm=$(kubectl logs pod/${POD} -c $CONTAINER_NAME -n $NAMESPACE >> $LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log)
        elif [ "$CONTAINER" = "n" ] && [ "$SEARCH" = "y" ]; then
            echo "Hiiiii, inside Option 3"
            comm=$(kubectl logs pod/${POD} -n $NAMESPACE | grep -i $SEARCH_PATTERN >> $LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log)
        elif [ "$CONTAINER" = "n" ] && [ "$SEARCH" = "n" ]; then
            echo "Option 4"
            comm=$(kubectl logs pod/${POD} -n $NAMESPACE >> $LOG_DIR/SMSF_logs_${POD}_$CURRENT_TIME.log)
        fi
    done < "$LOG_DIR/output_${POD_NAME}_$CURRENT_TIME"
done
