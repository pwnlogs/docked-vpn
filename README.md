# docked-vpn
A docker proxy with VPN support

## How to Use
### Starting Docked-VPN
You can start Docked-VPN with the following command:

    docker run -v $(pwd)/<path-to-config-dir>:/vpn --privileged seedbits/docked-vpn:latest

Breaking down the above command:

* `docker run`: The command to run docker container.
* `-v $(pwd)/<path-to-config-dir>:/vpn`: This option makes your config directory accessible to the Docked-VPN container. The path to this directory inside the container will be `/vpn`. Your config directory is expected to contain a bash file `run.sh` and any configuration files required by `run.sh`. Docked-VPN will execute `run.sh` to start OpenVPN with the configuration of your choice. Typically, `run.sh` contains the following single command: 

      openvpn --config my-config.conf --auth-user-pass my-creds.txt"
where `my-config.conf` is the OpenVPN configuration of your VPN provider and my-creds.txt contains the username and password for your VPN.
* `--privileged`: Flag that grants docker the privilege to create tun interface.
* `seedbits/docked-vpn`: The docker image name.

### Connecting to Docked-VPN
Once the container starts up, you can use port 3128 of the container to connect to the proxy. Configure your browser/software to use this proxy to route your traffic through the VPN.

For more information, please visit [my blog](https://blog.jithinpavithran.com/content/?article=docked-vpn).
