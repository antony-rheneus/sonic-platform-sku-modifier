# SONIC platform HWSKU migration online tool

copy all the files to HTTP server cgi-bin path.
This is a python based backend scripts to generate 
web page to login to a SONIC NOW running Hardware board
And list the available SKUs placed for the device which 
are /usr/share/sonic/device/{PLATFORM}/
{HWSKU1} - 32x400G
{HWSKU2} - 16x800G
...
{HWSKUx} - 128x100G

These port mode HWSKU be called as static port break out modes.

This tool will help to change to available SKUs of the device without any manual intervention
