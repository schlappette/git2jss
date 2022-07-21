#!/bin/bash

# Sets Turn Display Off after 15 minutes of idle time
systemsetup -setdisplaysleep 15

# Configures Computer Sleep settings
systemsetup -setcomputersleep never

# Sets Put Hard Disks to Sleep when possible to Off
systemsetup -setharddisksleep never

# Wakes the system upon network acccess (e.g., remote access of some type)
systemsetup -setwakeonnetworkaccess on

# Enables Startup automatically after a power failure
systemsetup -setrestartpowerfailure on

# Turns on (or wakes) the system at 07:00 am Daily
pmset repeat wakeorpoweron SMTWRFSU 07:00:00

# Turn off power nap
pmset -c darkwakes 0