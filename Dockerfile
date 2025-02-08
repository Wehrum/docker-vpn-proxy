# Use the OpenVPN client image as the base
FROM ghcr.io/wfg/openvpn-client:latest

# Install iptables if missing (just in case)
RUN apk add --no-cache iptables

# Copy NAT routing script
COPY proxy.sh config/proxy.sh
RUN chmod +x config/proxy.sh

ENTRYPOINT ["config/proxy.sh"]