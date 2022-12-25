#!/bin/bash
# Simple install script for 8188eu
# December, 25 2022 v0.0.1 borislavIvanov

help () {
	echo ""
	echo "usage: ./install.sh [options]"
	echo ""
	echo "options:"
	echo ""
	echo " -i         : Install Realtek RTL8188EU Wireless Lan Driver"
	echo " -u         : Uninstall Realtek RTL8188EU Wireless Lan Driver"
	echo " -h, --help : Displays this usage screen"
	echo ""
	exit
}

inst_drv () {
if ! command -v dkms >/dev/null 2>&1;then
	if [ ! -f "/lib/modules/$(uname -r)/kernel/drivers/net/wireless/8188eu.ko" ];then
		make clean; Error=$?
		make; Error=$?
		if [ "$Error" != "0" ];then
			echo "Install error: $Error"
			exit
		else
			if [ "$EUID" != "0" ];then
				echo "You need root permissions:"
				sudo make install; Error=$?
			else
				make install; Error=$?
			fi
		fi
	else
		echo "Module rtl8188eu already installed"
	fi
else
	if [[ ! "`dkms status`" =~ "rtl8188eu" ]];then
		if [ -e /usr/src/rtl8188eu-5.13.3 ];then
			if [ "$EUID" != "0" ];then
				echo "You need root permissions:"
				sudo rm -r /usr/src/rtl8188eu-5.13.3
				sudo cp -r "$(pwd)" /usr/src/rtl8188eu-5.13.3
			else
				rm -r /usr/src/rtl8188eu-5.13.3
				cp -r "$(pwd)" /usr/src/rtl8188eu-5.13.3
			fi
		else
			if [ "$EUID" != "0" ];then
				echo "You need root permissions:"
				sudo cp -r "$(pwd)" /usr/src/rtl8188eu-5.13.3
			else
				cp -r "$(pwd)" /usr/src/rtl8188eu-5.13.3
			fi
		fi
		if [ -f "/lib/modules/$(uname -r)/kernel/drivers/net/wireless/8188eu.ko" ];then
			if [ "$EUID" != "0" ];then
				echo "You need root permissions:"
				sudo rm -f /lib/modules/$(uname -r)/kernel/drivers/net/wireless/8188eu.ko
			else
				rm -f /lib/modules/$(uname -r)/kernel/drivers/net/wireless/8188eu.ko
			fi
		fi
		if [ "$EUID" != "0" ];then
			echo "You need root permissions:"
			sudo dkms add -m rtl8188eu -v 5.13.3; Error=$?
			sudo dkms build -m rtl8188eu -v 5.13.3; Error=$?
		else
			dkms add -m rtl8188eu -v 5.13.3; Error=$?
			dkms build -m rtl8188eu -v 5.13.3; Error=$?
		fi
		if [ "$Error" != "0" ];then
			echo "Install error: $Error"
			exit
		else
			if [ "$EUID" != "0" ];then
				echo "You need root permissions:"
				sudo dkms install -m rtl8188eu -v 5.13.3; Error=$?
			else
				dkms install -m rtl8188eu -v 5.13.3; Error=$?
			fi
		fi
	else
		echo "Module rtl8188eu already installed"
	fi
fi
}

uinst_drv () {
if ! command -v dkms >/dev/null 2>&1;then
	if [ -f "/lib/modules/$(uname -r)/kernel/drivers/net/wireless/8188eu.ko" ];then
		if [ "$EUID" != "0" ];then
			echo "You need root permissions:"
			sudo make uninstall; Error=$?
		else
			make uninstall; Error=$?
		fi
	else
		echo "Module rtl8188eu already uninstalled"
	fi
else
	if [[ "`dkms status`" =~ "rtl8188eu" ]];then
		if [ "$EUID" != "0" ];then
			echo "You need root permissions:"
			sudo dkms remove -m rtl8188eu -v 5.13.3 --all; Error=$?
		else
			dkms remove -m rtl8188eu -v 5.13.3 --all; Error=$?
		fi
	else
		echo "Module rtl8188eu already uninstalled"
	fi
fi
}

if [ -z "$1" ];then
	echo "[options] is not defined"
	help
elif [ "$1" = "-h" ] || [ "$1" = "--help" ];then
	help
elif [ "$1" = "-i" ];then
	echo "Install Realtek RTL8188EU Wireless Lan Driver..."
	inst_drv
elif [ "$1" = "-u" ];then
	echo "Uninstall Realtek RTL8188EU Wireless Lan Driver..."
	uinst_drv
else
	echo "Incorrect [options] "$1""
	help
fi
