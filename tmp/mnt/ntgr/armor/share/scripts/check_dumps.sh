#!/bin/sh

source "/opt/bitdefender/share/scripts/lib/setter.sh"

CHARON_BIN="/opt/bitdefender/bin/charon"
CHARON_CMD="LD_LIBRARY_PATH=/opt/bitdefender/lib ${CHARON_BIN}"
DUMPFOLDER="/opt/bitdefender/var/crash/"
ARKFOLDER="/opt/bitdefender/var/arks/"
INSTALL_DIR="/opt/bitdefender/"
KATASTIF_SERVICE="minidump"


logmsg() { echo "$*" >&2; }

get_module_version(){
  local app_id="$1"
  local module_name="$2"
  local version_file="/etc/bitdefender-release"
  if [ "$app_id" == "com.netgear.boxlight" ] || [ "$app_id" == "com.netgear.boxse" ]; then
    version_file="/opt/bitdefender/bitdefender-release"
  fi

  grep -E '^VERSION=' "${version_file}" 2>/dev/null | awk -F'[=~'] '{print $2}'
}

generate_archive(){
  mkdir -p $ARKFOLDER
  local dmp="${1}"
  archivename=""
  timestamp=`date +%s`
  local app_id=`LD_LIBRARY_PATH=/opt/bitdefender/lib ${CHARON_BIN} -c get_config -m app_id`

  if [ "$app_id" == "com.netgear.boxlight" ] || [ "$app_id" == "com.netgear.boxse" ]; then
    gzip -c -f ${DUMPFOLDER}$dmp > ${DUMPFOLDER}$dmp.gz
    rm ${DUMPFOLDER}$dmp
    dmp="${dmp}.gz"
  fi

  if [ ! -f ${DUMPFOLDER}config.cfg ]; then
    if [ "$app_id" == "com.netgear.boxlight" ] || [ "$app_id" == "com.netgear.boxse" ]; then
      grep -ve '^BUILD_ID' /opt/bitdefender/bitdefender-release > ${DUMPFOLDER}config.cfg
      # image_type, does not apply for netgear
      echo "TYPE=undefined" >> ${DUMPFOLDER}config.cfg
    else
      grep -ve '^BUILD_ID' /etc/bitdefender-release > ${DUMPFOLDER}config.cfg
    fi

    local dump_type=`LD_LIBRARY_PATH=/opt/bitdefender/lib ${CHARON_BIN} -c get_config -m dump_type`
    if [ $? -ne 0 ]; then
      logmsg "failed to generate config.cfg"
      rm ${DUMPFOLDER}config.cfg
      return 1
    fi

    echo "DUMP_TYPE=$dump_type" >> ${DUMPFOLDER}config.cfg
    echo "APP_ID=$app_id" >> ${DUMPFOLDER}config.cfg

    if [ "$app_id" == "com.bitdefender.boxse" ]; then
      FIPR=$(comcerto_otp --sn | xargs echo -n | sha256sum | awk '{print $1}')
    else
      FIPR=$(get_key /karma/fipr)
    fi
    echo "FIPR=$FIPR" >> ${DUMPFOLDER}config.cfg
  fi

  if [ "$app_id" == "com.netgear.boxlight" ] || [ "$app_id" == "com.netgear.boxse" ]; then
    # Netgear format: bddevicediscovery-0.dmp.gz
    local exe_name=$(basename ${dmp} | cut -d '.' -f 1 | cut -d '-' -f 1)
    local patch_ver="$(basename ${dmp} | cut -d '.' -f 1).patch.ver"
  else
    # BOX format: 1538485020.bddevicediscovery.4318.core.gz
    local exe_name=$(basename ${dmp} | cut -d '.' -f 2)
    local patch_ver="$(basename ${dmp} | cut -d '.' -f 1-3).patch.ver"
  fi
  local module_version=$(get_module_version "${app_id}")
  local extra_json="{\"crash_info\":{\"module_name\":\"${exe_name}\", \"module_version\" : \"${module_version}\"}}"
  LD_LIBRARY_PATH=/opt/bitdefender/lib /opt/bitdefender/bin/karma -submit -event_type=bd_module_crashed -extra_json "${extra_json}"

  random=`dd if=/dev/urandom bs=4 count=12 2>/dev/null | tr -dc 'a-zA-Z0-9' | cut -c1-6`
  archivename=d_${random}_${timestamp}.tar

  tar  -cf ${ARKFOLDER}${archivename} -C ${DUMPFOLDER} ${dmp} ${patch_ver} config.cfg 2> /dev/null
  rm -rf ${DUMPFOLDER}${dmp}
  rm -rf ${DUMPFOLDER}${patch_ver}
  echo ${ARKFOLDER}$archivename
}

check_dumps(){
  files=`ls ${DUMPFOLDER} | grep -ve ".cfg\|.patch.ver"`
  set -x
  for i in $files
  do
    ark=$(generate_archive $i)

    if [ -f ${CHARON_BIN} ];
    then
      LD_LIBRARY_PATH=/opt/bitdefender/lib ${CHARON_BIN} -c submit -s ${KATASTIF_SERVICE} -i $ark
    fi
  done
}

check_pending_dumps(){
  files=`ls ${ARKFOLDER} 2> /dev/null | grep tar`

  for i in $files
  do

    if [ -f ${CHARON_BIN} ];
    then
      LD_LIBRARY_PATH=/opt/bitdefender/lib ${CHARON_BIN} -c submit -s ${KATASTIF_SERVICE} -i ${ARKFOLDER}$i
    fi
  done
}

check_dumps

check_pending_dumps
