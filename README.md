# Docker VPN Proxy

- [Docker VPN Proxy](#docker-vpn-proxy)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
    - [Notes](#notes)
  - [Commands](#commands)
    - [Build Image](#build-image)
    - [Run Image](#run-image)
    - [Testing Proxy](#testing-proxy)
  - [Adding Proxy to Windows](#adding-proxy-to-windows)
  - [Connecting to Internal IP's From the Host](#connecting-to-internal-ips-from-the-host)

## Overview

Small repo that describes how to use Docker VPN Proxy.
This proxy allows you to setup a VPN connection within a docker container
and use that VPN connection in a host machine.

## Prerequisites

- Docker
- An existing OpenVPN server that is online
- A VPN config file

### Notes

- If VPN config file is protected with password
  - Create a file called `credentials.txt`
  - Put password inside it
    - Make sure the credential.txt and config file are in the same directory
  - Add `askpass credentials.txt` to the config file
- Make sure to add `dhcp-option` DNS settings if they are not included
  or you may experience internet connectivity issues within the container.
  - Example:

    ![example of open vpn config](./docs/images/openvpn_config_example.png)

## Commands

### Build Image

```bash
docker build -t openvpn-nat .
```

### Run Image

Image relies on port `3128`.
This is the port to use when connecting to the proxy

```bash
docker run --detach --name=openvpn-nat --cap-add=NET_ADMIN --device=/dev/net/tun --volume ~/DIRECTORY_TO_VPN_FILE:/data/vpn -p 3128:3128 -p 2222:2222 openvpn-nat
```

### Testing Proxy

Please note that this will only work with http/https (80 & 443)

```bash
curl --proxy http://localhost:3128 https://ifconfig.me
```

Check proxy settings in [proxy.sh](./proxy.sh)
If you get a connection error you may have to add your subnet.
`(line 255)`

## Adding Proxy to Windows

Navigate to `Settings > Proxy Settings > Manual proxy setup`

![Example of proxy](./docs/images/proxy_example.png)

## Connecting to Internal IP's From the Host

You can connect to internal ip's (for example an SSH or RDP server)
from the VPN Container on your host machine.

**Step 1:** Add a Port Forwarding Rule in Your VPN Container

Add the `-p` flag to specify a port you wish to expose from the container.
For this example we are using `2222` but you may pick any port as long as it's
not already in use.

After your container starts, run:

```bash
docker exec -it "container_name" sh
```

When inside the container run the following commands:

```bash
iptables -t nat -A PREROUTING -p tcp --dport 2222 -j DNAT --to-destination 10.0.0.92:22
iptables -t nat -A POSTROUTING -j MASQUERADE
```

This forwards `localhost:2222` to port 22, on `10.0.0.92` within the container.

This assumes `10.0.0.92` is an internal ip on your network that is hosting
an SSH server. You can change this to whatever IP/Port you want to expose.

You can test it by going back to the host machine and running

```bash
ssh -p 2222 user@localhost
```
