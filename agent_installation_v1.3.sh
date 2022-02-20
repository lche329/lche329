#!/bin/bash
# Determine OS platform
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
UNAME=$(uname)
# If Linux, try to determine specific distribution
if [ "${UNAME,,}" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        DISTRO=$(lsb_release -i | cut -d':' -f2 | sed s/'^\s'// | tr "[:upper:]" "[:lower:]" ) && echo ${DISTRO} > /tmp/linux_distro1.txt
    # Otherwise, use release info file
    else
        DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1 | tr "[:upper:]" "[:lower:]") && echo ${DISTRO} >/tmp/linux_distro2.txt
    fi
fi
# For everything else (or if above failed), just use generic identifier
[ "$DISTRO" == "" ] && echo $UNAME > /tmp/linux_distro.txt

for dist in $DISTRO

do
   if [ "${dist,,}" == "centos" ]; then
        echo ${dist} > /tmp/linux_specific.txt
	# To install curl instead of wget, which can later be used to get the MetaData.
	sudo yum -y install curl
	# To detect the specific CentOS version, thus installing corresponding packages
	COSVER=$(sudo cat /etc/os-release | grep "VERSION_ID" | sed '2,$d' | cut -d '=' -f 2 | cut -d '"' -f 2)

	if [ "${COSVER}" == "8" ] || [ "${COSVER}" -eq 8 ]; then
		curl https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/15876/download?i_agree_to_tenable_license_agreement=true -o "/tmp/NessusAgent-10.1.1-es8.x86_64.rpm"
		sudo rpm -ivh /tmp/NessusAgent-10.1.1-es8.x86_64.rpm
	elif [ "${COSVER}" == "7" ] || [ "${COSVER}" -eq 7 ]; then
		curl https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/15875/download?i_agree_to_tenable_license_agreement=true -o "/tmp/NessusAgent-10.1.1-es7.x86_64.rpm"
		sudo rpm -ivh /tmp/NessusAgent-10.1.1-es7.x86_64.rpm
	fi
	
	RESULTINSTALLATIONCOS=$?
#	sudo touch /tmp/NessusAgentInstallationStatus.txt
# 	sudo chmod 666 /tmp/NessusAgentInstallationStatus.txt
 	sudo echo "${RESULTINSTALLATIONCOS}" | sed "1i Returned installation status from shell is as follows:" > /tmp/NessusAgentInstallationStatus.txt
 	sudo rpm -qa |grep -i NessusAgent | sed "1i Installed agent is as follows:" >> /tmp/NessusAgentInstallationStatus.txt
 	[ "${RESULTINSTALLATIONCOS}" -eq 0 ] && sudo echo "Nessus Agent Installation Seems Successful at - $(date)" >> /tmp/NessusAgentInstallationStatus.txt
	sudo /bin/systemctl enable nessusagent.service && sudo /bin/systemctl start nessusagent.service
	sudo /opt/nessus_agent/sbin/nessuscli agent link --key=452cd6a398b03786a938304d73c026e70e3ba0d57a3207b54971fc25c602c330 --host=cloud.tenable.com --port=443 --groups="nectar_external" > /tmp/NessusAgentLinkingLog.txt 2>&1
	if [ $? -eq 0 ]; then 
		echo "Nessus_Agent_Linking_succeeds at - $(date)" >> /tmp/NessusAgentLinkingLog.txt
		exit 0
	else 
	    echo "Nessus_Agent_Linking_fails at - $(date)" >> /tmp/NessusAgentLinkingLog.txt
	    exit 88
	fi


   elif [ "${dist,,}" == "ubuntu" ]; then
	echo ${dist} > /tmp/linux_specific.txt
	# To install curl instead of wget, which can later be used to get MetaData info.
	sudo apt -y install curl
	# Download the NessusAgent
	curl https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/15882/download?i_agree_to_tenable_license_agreement=true --output "/tmp/NessusAgent-10.1.1-ubuntu1110_amd64.deb"
	sudo dpkg -i /tmp/NessusAgent-10.1.1-ubuntu1110_amd64.deb

	RESULTINSTALLATIONUBT=$?
#	sudo touch /tmp/NessusAgentInstallationStatus.txt
#	sudo chmod 666 /tmp/NessusAgentInstallationStatus.txt
	sudo echo "${RESULTINSTALLATIONUBT}" | sed "1i Returned installation status from shell is as follows:" > /tmp/NessusAgentInstallationStatus.txt
	sudo dpkg -l | grep -i NessusAgent | sed "1i Installed agent is as follows:" >> /tmp/NessusAgentInstallationStatus.txt
	[ "${RESULTINSTALLATIONUBT}" -eq 0 ] && sudo echo "Nessus Agent Installation Seems Successful at - $(date)" >> /tmp/NessusAgentInstallationStatus.txt
	sudo /bin/systemctl enable nessusagent.service && sudo /bin/systemctl start nessusagent.service
	sudo /opt/nessus_agent/sbin/nessuscli agent link --key=452cd6a398b03786a938304d73c026e70e3ba0d57a3207b54971fc25c602c330 --host=cloud.tenable.com --port=443 --groups="nectar_external" > /tmp/NessusAgentLinkingLog.txt 2>&1
	if [ $? -eq 0 ]; then 
		echo "Nessus_Agent_Linking_succeeds at - $(date)" >> /tmp/NessusAgentLinkingLog.txt
		exit 0
	else 
	    echo "Nessus_Agent_Linking_fails at - $(date)" >> /tmp/NessusAgentLinkingLog.txt
	    exit 88
	fi
	

   elif [ "${dist,,}" == "debian" ]; then
	echo ${dist} > /tmp/linux_specific.txt
	# To install curl instead of wget, which can later be used to get MetaData info.
	sudo apt -y install curl
	# Download the NessusAgent
	sudo curl https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/15871/download?i_agree_to_tenable_license_agreement=true --output "/tmp/NessusAgent-10.1.1-debian6_amd64.deb"
	sudo dpkg -i /tmp/NessusAgent-10.1.1-debian6_amd64.deb
	
	RESULTINSTALLATIONDEB=$?
#	sudo touch /tmp/NessusAgentInstallationStatus.txt
#	sudo chmod 666 /tmp/NessusAgentInstallationStatus.txt
	sudo echo "${RESULTINSTALLATIONDEB}" | sed "1i Returned installation status from shell is as follows:" > /tmp/NessusAgentInstallationStatus.txt
	sudo dpkg -l | grep -i NessusAgent | sed "1i Installed agent is as follows:" >> /tmp/NessusAgentInstallationStatus.txt
	[ "${RESULTINSTALLATIONDEB}" -eq 0 ] && sudo echo "Nessus Agent Installation Seems Successful at - $(date)" >> /tmp/NessusAgentInstallationStatus.txt
	sudo /bin/systemctl enable nessusagent.service && sudo /bin/systemctl start nessusagent.service
	sudo /opt/nessus_agent/sbin/nessuscli agent link --key=452cd6a398b03786a938304d73c026e70e3ba0d57a3207b54971fc25c602c330 --host=cloud.tenable.com --port=443 --groups="nectar_external" > /tmp/NessusAgentLinkingLog.txt 2>&1
	if [ $? -eq 0 ]; then 
		echo "Nessus_Agent_Linking_succeeds at - $(date)" >> /tmp/NessusAgentLinkingLog.txt
		exit 0
	else 
	    echo "Nessus_Agent_Linking_fails at - $(date)" >> /tmp/NessusAgentLinkingLog.txt
	    exit 88
	fi
	

   elif [ ! -f /tmp/linux_specific.txt ]; then
# This section is for Ubuntu and Debian 11
        sudo apt -y install ssmtp mailutils
	RESULT=$?
	echo $RESULT > /tmp/debian11.txt
	if [ $RESULT -eq 0 ]; then
	sudo chmod 666 /etc/ssmtp/ssmtp.conf
	sudo echo "root=postmaster" > /etc/ssmtp/ssmtp.conf && sudo echo "mailhub=smtp.gmail.com:587" >> /etc/ssmtp/ssmtp.conf && sudo echo "AuthUser=metric128256@gmail.com" >> /etc/ssmtp/ssmtp.conf && sudo echo "AuthPass=@4Verizon" >> /etc/ssmtp/ssmtp.conf && sudo echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf && sudo echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf 
	echo "Unkown version - $(uname -a) has been launched." | mail -s "Seems an unkown Linux image has just launched" lche329@aucklanduni.ac.nz
	exit 0
# This section is for Debian 10 and lower, which do not have the ssmtp util available in the apt. 
	elif [ $RESULT -ne 0 ] && [ ${dist,,}==debian ]; then
	RESULT1=$?
	echo ${dist,,} > /tmp/variable10.txt
	export DEBIAN_FRONTEND="noninteractive" 
	#apt-get -y --allow-unauthenticated --force-yes -o DPkg::Options::="--force-overwrite" -o DPkg::Options::="--force-confdef" install x11-common 
	apt -y install msmtp msmtp-mta mailutils
	echo "$RESULT1" > /tmp/stage0.txt
	echo "$DEBIAN_FRONTEND" >> /tmp/stage0.txt
	sudo touch /etc/msmtprc
	sudo echo "defaults" > /etc/msmtprc && sudo echo "auth on" >> /etc/msmtprc && sudo echo "tls on" >> /etc/msmtprc && sudo echo "tls_trust_file /etc/ssl/certs/ca-certificates.crt" >> /etc/msmtprc && sudo echo "logfile ~/.msmtp.log" >> /etc/msmtprc && sudo echo "account gmail" >> /etc/msmtprc && sudo echo "host smtp.gmail.com" >> /etc/msmtprc && sudo echo "port 587" >> /etc/msmtprc && sudo echo "from metric128256@gmail.com" >> /etc/msmtprc && sudo echo "user metric128256" >> /etc/msmtprc && sudo echo "password @4Verizon" >> /etc/msmtprc && sudo echo "account default : gmail" >> /etc/msmtprc
	echo "Unkown version - $(uname -a) has been launched." | mail -s "Seems an unkown Linux image has just launched" lche329@aucklanduni.ac.nz
	echo "$RESULT1" > /tmp/stage1.txt
#To determine if the above succeeds, if yes then exit.
	if [ $RESULT1 -eq 0 ]; then 
		echo "Debian 10 succeeds" > /tmp/d10.txt
		exit 0 
	fi
# This section is supposedly for Centos 7, however, it is temperamental - improvement needed
	else
		yum -y --enablerepo=extras install epel-release && sudo yum -y install ssmtp
	sudo echo "root=postmaster" > /etc/ssmtp/ssmtp.conf && sudo echo "mailhub=smtp.gmail.com:587" >> /etc/ssmtp/ssmtp.conf && sudo echo "AuthUser=metric128256@gmail.com" >> /etc/ssmtp/ssmtp.conf && sudo echo "AuthPass=@4Verizon" >> /etc/ssmtp/ssmtp.conf && sudo echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf && sudo echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
	echo "Uknown version - $(uname -a) has been launched." | ssmtp -s "Seems an unknown Linux image has just launched" lche329@aucklanduni.ac.nz 
	echo "$?" > /tmp/shresult.txt
	fi
   fi
done

unset UNAME
unset DISTRO
