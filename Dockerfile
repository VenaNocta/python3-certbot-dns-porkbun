FROM python:3.10-alpine AS build-image

RUN apk add --no-cache gcc musl-dev libffi-dev openssl-dev cargo git \
     && if [[ $(uname -m) == armv6* ||  $(uname -m) == armv7* ]]; then \
          mkdir -p ~/.cargo/registry/index \
          && cd ~/.cargo/registry/index \
          && git clone --bare https://github.com/rust-lang/crates.io-index.git github.com-1285ae84e5963aae; \
        fi
        # workaround for cryptography arm build issue: see https://github.com/pyca/cryptography/issues/6673

WORKDIR /certbot_dns_porkbun

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ADD requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

RUN pip install .


FROM python:3.10-alpine
COPY --from=build-image /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["certbot"]

LABEL org.opencontainers.image.source="https://github.com/infinityofspace/certbot_dns_porkbun"
LABEL org.opencontainers.image.licenses="MIT"
