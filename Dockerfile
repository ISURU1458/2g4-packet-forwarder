ARG ARCH
ARG TAG
ARG BUILD_DATE

# Builder image
FROM balenalib/${ARCH}-debian:buster-build as builder
ARG ARCH

# Switch to working directory for our app
WORKDIR /app

# Checkout and compile remote code
COPY builder/* ./
RUN chmod +x *.sh
RUN ARCH=${ARCH} ./build.sh

# Runner image
FROM balenalib/${ARCH}-debian:buster-run as runner
ARG ARCH
ARG TAG
ARG BUILD_DATE

# Image metadata
LABEL maintainer="xose.perez@gmail.com"
LABEL authors="xose.perez@gmail.com"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=${BUILD_DATE}
LABEL org.label-schema.name="2.4GHz Packet Forwarder"
LABEL org.label-schema.description="LoRaWAN UDP Packet Forwarder for 2.4GHz Gateways"
LABEL org.label-schema.vcs-type="Git"
LABEL org.label-schema.vcs-url="https://github.com/xoseperez/2g4-packet-forwarder"
LABEL org.label-schema.vcs-ref=${TAG}
LABEL org.label-schema.arch=${ARCH}
LABEL org.label-schema.license="BSD License 2.0"

# Install required runtime packages
RUN install_packages jq vim

# Switch to working directory for our app
WORKDIR /app

# Copy fles from builder and repo
COPY --from=builder /app/repo/packet_forwarder/lora_pkt_fwd /app/lora_pkt_fwd
COPY --from=builder /app/repo/packet_forwarder/global_conf.json /app/global_conf.json
COPY --from=builder /app/repo/util_chip_id/chip_id /app/chip_id
COPY runner/*.sh ./
RUN chmod +x *.sh

# Launch our binary on container startup.
CMD ["bash", "start.sh"]
