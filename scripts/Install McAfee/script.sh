#!/bin/bash
# This script will Install the McAfee FrameAgent for MAC and then perform an update.

# Install the FrameAgent
/Library/Application\ Support/McAfee_Files/install.sh -i


# Set a custom property value if also pulling software from the EPO
 "/Library/McAfee/cma/bin/maconfig" -custom -prop1 "ApplyTag-OSXInstallESP"

# Collect and sent properties
"/Library/McAfee/cma/bin/cmdagent" -p

# Sleep for 30 seconds
"/bin/sleep" 30

# Check for new policies
"/Library/McAfee/cma/bin/cmdagent" -c

# Sleep for 30 seconds
"/bin/sleep" 30

# Enforce policies locally
"/Library/McAfee/cma/bin/cmdagent" -e


# Sleep script (use 60 seconds if not using custom properties and 600 if using custom properties)
"/bin/sleep" 600

# Clear custom propeties (If Applicable)
"/Library/McAfee/cma/bin/maconfig" -custom -prop1 ""

# Sleep for 30 seconds
"/bin/sleep" 30

# Collect and sent properties
"/Library/McAfee/cma/bin/cmdagent" -p
