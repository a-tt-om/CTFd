FROM ghcr.io/ctfd/ctfd:3.8.2 AS build
USER root

WORKDIR /opt/CTFd

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libssl-dev \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add SSO plugin
RUN git clone https://github.com/a-tt-om/CTFd-SSO-plugin CTFd/plugins/CTFd-SSO-plugin
# Add First Blood plugin
RUN git clone https://github.com/SoICT-BKSEC/CTFd-FirstBlood CTFd/plugins/CTFd-FirstBlood
# Add Docker plugin
RUN git clone https://github.com/a-tt-om/CTFd-Docker-Plugin CTFd/plugins/containers

RUN pip install --no-cache-dir -r requirements.txt \
    && for d in CTFd/plugins/*; do \
        if [ -f "$d/requirements.txt" ]; then \
            pip install --no-cache-dir -r "$d/requirements.txt";\
        fi; \
    done;


FROM ghcr.io/ctfd/ctfd:3.8.2 AS release
WORKDIR /opt/CTFd

# Copy venv with plugin dependencies
COPY --chown=1001:1001 --from=build /opt/venv /opt/venv
# Copy SSO plugin
COPY --chown=1001:1001 --from=build /opt/CTFd/CTFd/plugins/CTFd-SSO-plugin /opt/CTFd/CTFd/plugins/CTFd-SSO-plugin
# Copy First Blood plugin
COPY --chown=1001:1001 --from=build /opt/CTFd/CTFd/plugins/CTFd-FirstBlood /opt/CTFd/CTFd/plugins/CTFd-FirstBlood
# Copy Docker plugin
COPY --chown=1001:1001 --from=build /opt/CTFd/CTFd/plugins/containers /opt/CTFd/CTFd/plugins/containers

USER 1001
EXPOSE 8000
ENTRYPOINT ["/opt/CTFd/docker-entrypoint.sh"]
