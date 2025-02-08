# Use the OpenVPN client image as the base
FROM ghcr.io/wfg/openvpn-client:latest

# Copy NAT routing script
COPY proxy.sh config/proxy.sh
RUN chmod +x config/proxy.sh

ENTRYPOINT ["config/proxy.sh"]