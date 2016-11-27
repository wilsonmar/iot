#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# system_info.py
# from https://github.com/jetbloom/iot-utilities/
# For running on Raspian Jenny on Raspberry Pi 3 B 
# Edited by wilsonmar@gmail.com
# Adapted from http://cagewebdev.com/raspberry-pi-showing-some-system-info-with-a-python-script/

import subprocess

# From http://code.activestate.com/recipes/577972-disk-usage/
import os
import collections # for namedtuple

def get_pi_serial():
  "Extract 16-digit serial from cpuinfo file"
  cpuserial = "0000000000000000"
  try:
    f = open('/proc/cpuinfo','r')
    for line in f:
      if line[0:6]=='Serial':
        cpuserial = line[10:26]
    f.close()
  except:
    cpuserial = ""
  return cpuserial


def get_ram():
    "Returns a tuple (total ram, available ram) in megabytes: See www.linuxatemyram.com"
    try:
        s = subprocess.check_output(["free","-m"])
        lines = s.split('\n')
        return ( int(lines[1].split()[1]), int(lines[2].split()[3]) )
    except:
        return 0

def get_process_count():
    "Returns the number of processes"
    try:
        s = subprocess.check_output(["ps","-e"])
        return len(s.split('\n'))
    except:
        return 0

def get_up_stats():
    "Returns a tuple (uptime, 5 min load average): "
    try:
        s = subprocess.check_output(["uptime"])
        load_split = s.split('load average: ')
        load_five = float(load_split[1].split(',')[1])
        up = load_split[0]
        up_pos = up.rfind(',',0,len(up)-4)
        up = up[:up_pos].split('up ')[1]
        return ( up , load_five )
    except:
        return ( "", 0 )

def get_connections():
    "Returns the number of network connections: "
    try:
        s = subprocess.check_output(["netstat","-tun"])
        return len([x for x in s.split() if x == 'ESTABLISHED'])
    except:
        return 0

def get_temp_celsius():
    "Returns the temperature in degrees C: "
    try:
        s = subprocess.check_output(["/opt/vc/bin/vcgencmd","measure_temp"])
        return float(s.split('=')[1][:-3])
    except:
        return 0

def get_temp_fahrenheit():
    "Returns the temperature in degrees F: "
    # 28.0 C = 82.4, 37.5 C = 99.5 F, 54.5 C = 130.1 F
    try:
        celsius = get_temp_celsius()
        return (celsius * 1.8) + 32
    except:
        return 0

def get_ipaddress():
    "Returns the current IP address: "
    arg='ip route list'
    p=subprocess.Popen(arg,shell=True,stdout=subprocess.PIPE)
    data = p.communicate()
    split_data = data[0].split()
    ipaddr = split_data[split_data.index('src')+1]
    return ipaddr

def get_cpu_arm_freq():
    "Returns the current CPU ARM speed: "
    f = os.popen('/opt/vc/bin/vcgencmd get_config arm_freq')
    cpu = f.read()
    return cpu.replace('\n', ' ').replace('\r', '')
    # Remove new lines

def get_cpu_core_freq():
    "Returns the current CPU core speed: "
    f = os.popen('/opt/vc/bin/vcgencmd get_config core_freq')
    cpu = f.read()
    return cpu.rstrip('\r\n')

def get_cpu_sdram_freq():
    "Returns the current CPU sdram speed: "
    f = os.popen('/opt/vc/bin/vcgencmd get_config sdram_freq')
    cpu = f.read()
    return cpu.replace('\n', ' ').replace('\r', '')


_ntuple_diskusage = collections.namedtuple('usage', 'total used free')
if hasattr(os, 'statvfs'):  # POSIX
    def disk_usage(path):
        st = os.statvfs(path)
        gb=1073741824 # thousand million bytes
        free = st.f_bavail * st.f_frsize / gb
        total = st.f_blocks * st.f_frsize / gb
        used = (st.f_blocks - st.f_bfree) * st.f_frsize / gb
        return _ntuple_diskusage(total, used, free)

elif os.name == 'nt':       # Windows
    import ctypes
    import sys

    def disk_usage(path):
        _, total, free = ctypes.c_ulonglong(), ctypes.c_ulonglong(), \
                           ctypes.c_ulonglong()
        if sys.version_info >= (3,) or isinstance(path, unicode):
            fun = ctypes.windll.kernel32.GetDiskFreeSpaceExW
        else:
            fun = ctypes.windll.kernel32.GetDiskFreeSpaceExA
        ret = fun(path, ctypes.byref(_), ctypes.byref(total), ctypes.byref(free))
        if ret == 0:
            raise ctypes.WinError()
        used = total.value - free.value
        return _ntuple_diskusage(total.value, used, free.value)
else:
    raise NotImplementedError("platform not supported")

def bytes2human(n):
    symbols = ('K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y')
    prefix = {}
    for i, s in enumerate(symbols):
        prefix[s] = 1 << (i+1)*10
    for s in reversed(symbols):
        if n >= prefix[s]:
            value = float(n) / prefix[s]
            return '%.1f%s' % (value, s)
    return "%sGB" % n

###########
disk_usage.__doc__ = __doc__
if __name__ == '__main__':
    print 'Serial number:     '+get_pi_serial().lstrip("0")
    print 'IP-address:        '+get_ipaddress()
    print 'Up time hours:     '+get_up_stats()[0]
    print 'Free RAM:          '+str(get_ram()[1])+' of '+str(get_ram()[0])+' MB total (1GB)'
    print '# of connections:  '+str(get_connections())
    print '# of processes:    '+str(get_process_count())

    #SDDISK_pct_free = str((SDDISK_usage.free / SDDISK_usage.total) * 10000 )
    SDDISK_usage = disk_usage(os.getcwd()) #print os.getcwd() > /home/pi/gits/wilsonmar/iot
    print 'SD card disk space '+bytes2human(SDDISK_usage.free) \
        + ' free and '+bytes2human(SDDISK_usage.used) \
        + ' used of '+bytes2human(SDDISK_usage.total)
    USBDISK_usage = disk_usage('/dev/sda1') 
    print 'SD card disk space '+bytes2human(USBDISK_usage.free) \
        + ' free and '+bytes2human(USBDISK_usage.used) \
        + ' used of '+bytes2human(USBDISK_usage.total)

    print 'CPU Temperature:   '+str(get_temp_celsius()) +'C = '+ str(get_temp_fahrenheit()) +'F' \
        + ' (Max. 85C = 185F)'
    print 'CPU speed  '+str(get_cpu_arm_freq())  +" (Default:1200 Under:600 Over:1350)"
    print 'CPU speed  '+str(get_cpu_core_freq())+"  (Default: 400 Under:250 Over:500)"
    print 'CPU speed '+str(get_cpu_sdram_freq()) +" (Default: 450 Under:450)"
    # https://retroresolution.com/2016/03/24/overclocking-the-raspberry-pi-3-pragmatism-and-optimising-for-single-vs-multicore-performance/
