#!/bin/sh
set -e

########################################
# script starts here
########################################

printf "#####\n"
printf "# Container starting up!\n"
printf "#####\n"

# Test variable for timezone
if [[ -z "$TZ" ]]; then
    printf "# WARN: TZ is undefined!\n"
else
    printf "# STATE: Setting container timezone to ${TZ}\n"
    ln -sf /usr/share/zoneinfo/"${TZ}" /etc/localtime
    echo "${TZ}" > /etc/timezone
fi

# Define default executable args
export VELSERV_ARGS="-p 3788 -f"

# Set logging
if [[ -z "$LOG_DISABLE" ]]; then
    export LOG_DISABLE="true"
fi

if [[ "$LOG_DISABLE" == "true" ]]; then
    printf "# STATE: Logging disabled\n"
else
    printf "# STATE: Logging enabled\n"
    
    if [[ -z "$LOG_LEVEL" ]]; then
        printf "# WARN: LOG_LEVEL is undefined, fallback to debug!\n"
        export LOG_LEVEL="debug"
    fi

    case $LOG_LEVEL in
        debug)
            export VELSERV_ARGS="${VELSERV_ARGS=} -v"
            ;;
        debug_com)
            export VELSERV_ARGS="${VELSERV_ARGS=} -vvv"
            ;;
        debug_socket)
            export VELSERV_ARGS="${VELSERV_ARGS=} -vvvvvv"
            ;;
        *)
            printf "# WARN: ${LOG_LEVEL} is not supported, fallback to debug!\n"
            export VELSERV_ARGS="${VELSERV_ARGS=} -v"
    esac
fi

# Set running mode (gateway, server, client)
if [[ -z "$VELSERV_MODE" ]]; then
    printf "# WARN: VELSERV_MODE is undefined, fallback to gateway mode!\n"
    export VELSERV_MODE="gateway"
fi

case $VELSERV_MODE in
    gateway)
        printf "# STATE: MODE = gateway\n"
        ;;
    server)
        printf "# STATE: MODE = server, client and gateway disabled\n"
        export VELSERV_ARGS="${VELSERV_ARGS} -s"
        ;;
    client)
        printf "# STATE: MODE = client, server and gateway disabled\n"

        if [[ -z "$REMOTE_ADDR" ]]; then
            printf "# WARN: REMOTE_ADDR is undefined, using default address 127.0.0.1!\n"
            export REMOTE_ADDR="127.0.0.1"
        fi

        export VELSERV_ARGS="${VELSERV_ARGS} -c -a ${REMOTE_ADDR}"
        ;;
    *)
        printf "# WARN: ${VELSERV_MODE} is not supported, fallback to gateway mode!\n"
esac

# Start VelserV
printf "# STATE: Starting VelServ\n"
exec /usr/local/bin/velserv ${VELSERV_ARGS}