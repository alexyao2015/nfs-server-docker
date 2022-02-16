#!/command/with-contenv sh
. "/usr/local/bin/logger"
program_name="create-exports"

# Ensure at least 1 SHARED_DIRECTORY is defined
if [ -z "${SHARED_DIRECTORY_1}" ]; then
  echo "At least one SHARED_DIRECTORY_x must be defined" | error "[${program_name}] "
  echo "These are numbered variables starting with 1" | error "[${program_name}] "
  echo "For example, the first one will be SHARED_DIRECTORY_1" | error "[${program_name}] "
  exit 1
fi

# https://unix.stackexchange.com/a/507242
for (( i=1 ; ; i++ )); do
    shared="SHARED_DIRECTORY_${i}"
    [ "${!shared+x}" ] || break # see if it exists
    mount_settings="MOUNT_SETTINGS_${i}"
    if [ ${!mount_settings} ]; then
        mount_settings="${!mount_settings}"
    else
        mount_settings="${DEFAULT_MOUNT_SETTINGS}"
        echo "The mount settings for shared directory ${i} have not been defined" | warn "[${program_name}] "
        echo "Using default settings for this mount point" | warn "[${program_name}] "
        echo "The settings used for this mount point are:" | warn "[${program_name}] "
        echo "${mount_settings}" | warn "[${program_name}] "
    fi
    echo "Using the following settings for mount ${i}:" | info "[${program_name}] "
    echo "${!shared} ${!mount_settings}" | info "[${program_name}] "
    echo "${!shared} ${!mount_settings}" >> /etc/exports
done
