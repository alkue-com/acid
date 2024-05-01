ARG AZURE_CLI_VERSION="2.60.0"
FROM mcr.microsoft.com/azure-cli:${AZURE_CLI_VERSION}

RUN mkdir -p /opt/az
WORKDIR /opt/az

COPY --chmod=750 entrypoint.sh entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
