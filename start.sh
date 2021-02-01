#!/bin/bash
# Check if vpn directory is mounted
echo "[INFO ] Running verifications ..."
if [ ! -d "/vpn" ]; then
    # if vpn directory does not exist
    echo ""
    echo "[ERROR] Configuration directory not found!"
    echo ""
    echo "[HINT ] Docked-VPN requires a script named 'run.sh' in '/vpn' directory of the container."
    echo "[HINT ] You can load the script by adding the script folder as a volume."
    echo "[HINT ] Use '-v absolute-path-to-host-dir:/vpn' option to add the volume."
    echo ""
    echo "[HINT ] The directory can also contain other required config files."
    echo "[HINT ] run.sh typically contains the following single line:"
    echo "[HINT ]     openvpn --config my-config.conf --auth-user-pass my-creds.txt"
    echo "[HINT ] where, 'my-config.conf' and 'my-creds.txt' are files in the same directory as run.sh"
    echo "[HINT ] 'my-config.conf' will have the openvpn config of your VPN provider and 'my-creds.txt' will contain the credentials."
    echo ""
    echo ""
    echo "[HINT ] Use following command to start docked-vpn:"
    echo "[HINT ]     docker run -v \$(pwd)/relative-path-to-config-dir:/vpn --privileged seedbits/dockedvpn:latest"
    echo ""
    echo ""
    exit 1
fi
# Check if run.sh exists
if [ ! -f /vpn/run.sh ]; then
    echo ""
    echo "[ERROR] run.sh not found!"
    echo ""
    echo "[HINT ] Docked-VPN requires a script named 'run.sh' in '/vpn' directory of the container."
    echo "[HINT ] You can load the script by adding the script folder as a volume."
    echo "[HINT ] Use '-v host-dir:/vpn' option to add the volume."
    echo ""
    echo "[HINT ] The directory can also contain other required config files."
    echo "[HINT ] run.sh typically contains the following single line:"
    echo "[HINT ]     openvpn --config my-config.conf --auth-user-pass my-creds.txt"
    echo "[HINT ] where, 'my-config.conf' and 'my-creds.txt' are files in the same directory as run.sh"
    echo "[HINT ] 'my-config.conf' will have the openvpn config of your VPN provider."
    echo "[HINT ] 'my-creds.txt' will contain the credentials."
    echo ""
    echo ""
    echo "[HINT ] Use following command to start docked-vpn:"
    echo "[HINT ]     docker run -v \$(pwd)/relative-path-to-config-dir:/vpn --privileged seedbits/dockedvpn:latest"
    echo ""
    echo ""
    exit 1
fi
# Check if the container is privileged
ip link add dummy0 type dummy >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo ""
    echo "[ERROR] Unprivileged container!"
    echo ""
    echo "[HINT ] Docked-VPN should be run with '--privileged' flag."
    echo "[HINT ] This is required since Docked-VPN needs to create tun interface for openvpn."
    echo ""
    echo ""
    echo "[HINT ] Use following command to start docked-vpn:"
    echo "[HINT ]     docker run -v \$(pwd)/relative-path-to-config-dir:/vpn --privileged seedbits/dockedvpn:latest"
    echo ""
    echo ""
    exit 1
fi
echo "[INFO] Verfications done"
# OpenVPN
echo "[INFO] Updating DNS configuration"
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
echo "[INFO ] Starting openvpn"
cd /vpn
bash run.sh &
# Squid
echo "[INFO ] Checking openvpn status"
ip a | grep -q tun && touch /started-vpn || rm -f /started-vpn
i=0
while [ ! -f /started-vpn ]; do
    if [[ "$i" -gt 15 ]]; then
        echo "[ERROR] Wait time exceeded, exiting ..."
        exit 1
    fi
    echo "[INFO ] Waiting for openvpn to start ... (${i} sec / 10 sec)"
    sleep 1
    ((i++))
    ip a | grep -q tun && touch /started-vpn || rm -f /started-vpn
done
echo "[INFO ] Waiting for 3 secs ..."
sleep 3
echo "[INFO ] Starting squid ..."
squid
echo "--------------------------------------------------------"
echo "[INFO ] Started proxy at "$(ip a | grep eth0 | grep -o -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v "255.255")":3128"
echo "--------------------------------------------------------"
wait
