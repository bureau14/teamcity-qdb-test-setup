#!/bin/bash

set -xe

SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/cleanup.sh"

check_existing_instances || true

echo "Killing ${QDBD} instances..."
case "$(uname)" in
    MINGW*)
        # we need double slashes for the flag to be recognized
        # a simple slash would cause this error: Invalid argument/option - 'C:/Program Files/Git/IM'.
        #
        # See http://www.mingw.org/wiki/Posix_path_conversion
        Taskkill //IM ${QDBD} //F || true
    ;;
    *)
        pkill -SIGKILL -f ${QDBD} || true
    ;;
esac

if [[ $(($(count_instances))) != 0 ]]; then
    sleep 30
fi

echo "Cluster insecure:"
print_instance_log ${LOG_DIR_INSECURE} ${CONSOLE_LOG_INSECURE} ${CONSOLE_ERR_LOG_INSECURE}

echo "Cluster secure:"
print_instance_log ${LOG_DIR_SECURE} ${CONSOLE_LOG_SECURE} ${CONSOLE_ERR_LOG_SECURE}

cleanup

if [[ $(($(count_instances))) != 0 ]]; then
    echo "${QDBD} instances were not killed properly"
    exit 1
fi
