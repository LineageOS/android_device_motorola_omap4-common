# Copyright (C) 2012 The Android Open Source Project
# Copyright (C) 2015 The CyanogenMod Project
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import types
import common

"""Custom OTA commands for Motorola omap4 devices"""

def FullOTA_InstallBegin(info):
	info.script.AppendExtra('assert(getprop("ro.build.selinux") == "1" || abort("This package needs a recovery with full SELinux-support"););')

def _WriteRawImage(self, mount_point, fn, mapfn=None):
	pass

def _FormatPartition(self, partition):
	self.Mount(partition)
	self.AppendExtra('delete_recursive("'+partition+'");')
	self.Unmount(partition)

def _Mount(self, mount_point, mount_options_by_format=""):
	fstab = self.fstab
	if mount_point == "/system" and fstab and fstab[mount_point].fs_type == "ext4":
		fstab[mount_point].fs_type = "ext3"
	self.OldMount(mount_point, mount_options_by_format)

def _MakeRecoveryPatch(input_dir, output_sink, recovery_img, boot_img,
                      info_dict=None):
	return

def FullOTA_Assertions(info):
	info.script.WriteRawImage = types.MethodType(_WriteRawImage, info.script)
	info.script.FormatPartition = types.MethodType(_FormatPartition, info.script)
	info.script.OldMount = info.script.Mount
	info.script.Mount = types.MethodType(_Mount, info.script)
	common.MakeRecoveryPatch = types.MethodType(_MakeRecoveryPatch, common)
