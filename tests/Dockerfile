FROM buildkite/plugin-tester:latest

# Install git
RUN apk update
RUN apk add git

# Install bats-file
# https://github.com/ztombol/bats-file
RUN mkdir -p /usr/local/lib/bats/bats-file \
    && curl -sSL https://github.com/ztombol/bats-file/archive/v0.2.0.tar.gz -o /tmp/bats-file.tgz \
    && tar -zxf /tmp/bats-file.tgz -C /usr/local/lib/bats/bats-file --strip 1 \
    && printf 'source "%s"\n' "/usr/local/lib/bats/bats-file/load.bash" >> /usr/local/lib/bats/load.bash \
    && rm -rf /tmp/bats-file.tgz
