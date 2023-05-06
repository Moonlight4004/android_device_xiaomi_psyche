#!/bin/bash
# This file is generated for Xiaomi 12X (psyche)

git_check_dir(){
	if [[ ! -d $3 ]];then
		mkdir -p $(dirname $3)
		git clone --depth=1 $1 -b $2 $3
	else
		echo -e "\033[1;32m=>\033[0m Found $3"
	fi
}

psyche_deps(){
	# use git_check_dir to setup dependencies
	# hardware/xiaomi: use AOSPA

	git_check_dir https://github.com//LineageOS/android_hardware_xiaomi lineage-20 hardware/xiaomi

	git_check_dir https://github.com/stuartore/android_device_xiaomi_psyche $1 device/xiaomi/psyche
	git_check_dir https://gitlab.com/stuartore/android_vendor_xiaomi_psyche $2 vendor/xiaomi/psyche
	git_check_dir https://gitlab.com/stuartore/vendor_xiaomi_psyche-firmware thirteen vendor/xiaomi-firmware/psyche
	git_check_dir https://github.com/VoidUI-Devices/kernel_xiaomi_sm8250.git aosp-13 kernel/xiaomi/void-aosp-sm8250

	# you can also use xiaomi_sm8250_devs kernel
	#git_check_dir https://github.com/xiaomi-sm8250-devs/android_kernel_xiaomi_sm8250.git lineage-20 kernel/xiaomi/devs-sm8250

	# clang
	git_check_dir https://github.com/EmanuelCN/zyc_clang-14.git master prebuilts/clang/host/linux-x86/ZyC-clang

	# other
	echo 'include $(call all-subdir-makefiles)' > vendor/xiaomi-firmware/Android.mk

	# type info when exit
	if [[ -d hardware/xiaomi ]] && [[ -d device/xiaomi/psyche ]] && [[ -d vendor/xiaomi/psyche ]] && [[ kernel/xiaomi/void-aosp-sm8250 ]] && [[ -d vendor/xiaomi-firmware/psyche ]] && [[ -d prebuilts/clang/host/linux-x86/ZyC-clang ]];then
		echo -e "\n\033[1;32m=>\033[0m here you're on the way, eg: lunch"
	fi
}

psyche_kernel_patch(){
	# need remove 2 techpack Android.mk
	psyche_kernel_path=$(grep TARGET_KERNEL_SOURCE device/xiaomi/psyche/BoardConfig.mk | grep -v '#' | sed 's/TARGET_KERNEL_SOURCE//g' | sed 's/:=//g' | sed 's/[[:space:]]//g')

	rm -f $psyche_kernel_path/techpack/data/drivers/rmnet/perf/Android.mk
	rm -f $psyche_kernel_path/techpack/data/drivers/rmnet/shs/Android.mk	
}

psyche_rom_select(){
	select rom_to_build in "PixelExperience 13" "Superior 13" "Crdroid 13" "RiceDroid 13"
	do
		case $rom_to_build in
			"PixelExperience 13")
				dt_branch="thirteen"
				;;
			"Superior 13*")
				dt_branch="superior-13"
				;;
			"RiceDroid 13")
				dt_branch="rice-13"
				;;
			*)
				dt_branch="thirteen"
				#exit 1
				;;
		esac
		break
	done
}

psyche_rom_setup(){
	if [[ -d hardware/xiaomi ]] && [[ -d device/xiaomi/psyche ]] && [[ -d vendor/xiaomi/psyche ]] && [[ -d kernel/xiaomi/void-aosp-sm8250 ]] && [[ -d vendor/xiaomi-firmware/psyche ]] && [[ -d prebuilts/clang/host/linux-x86/ZyC-clang ]];then
		return
	fi

	if [[ ! $(grep 'revision="android-13' .repo/manifests/default.xml) ]];then echo -e "\033[1;33m=>\033[0m SKIP - source code is \033[1;33mnot Android 13\033[0m";return;fi
	rom_str="$(grep 'url' .repo/manifests.git/config | uniq | sed 's/url//g' | sed 's/=//g' | awk  -F '/' '{print $4}')"
	
	select rom_version in "Stable" "Fastcharge"
	do
		case $rom_version in
			"Stable")
				declare -i rom_stable=1
				;;
			*)
				declare -i rom_stable=0
				;;
		esac
		break
	done

	if [[ ! -d device/xiaomi/psyche ]];then
		case $rom_str in
			"PixelExperience")
				dt_branch="thirteen"
				;;
			"SuperiorOS")
				dt_branch="superior-13"
				;;
			"ricedroidOSS")
				dt_branch="rice-13"
				;;
			*)
				psyche_rom_select
				;;
		esac
	fi

	dt_branch_sel="${dt_branch}"
	if [[ $rom_stable -eq 0 ]];then
		dt_branch="${dt_branch_sel}-unstable"
		vendor_branch='superior-13-unstable'
	else
		vendor_branch='thirteen'
	fi

	echo -e "\033[32m=>\033[0m Detect \033[1;36m${rom_str}\033[0m and select device branch \033[1;32m${dt_branch}\033[0m\n"
	psyche_deps ${dt_branch} ${vendor_branch}
}

psyche_rom_setup
psyche_kernel_patch
