# Caffeinate!!!
caffeinate -dis &
caffeinatePID=$!

JAMFBIN="/usr/local/jamf/bin/jamf"

# Run Adobe CC 2019 VAPAD Bundle PKG
$JAMFBIN policy -event installadobecc2019vapad -verbose;

# Decaffeinate
kill $caffeinatePID