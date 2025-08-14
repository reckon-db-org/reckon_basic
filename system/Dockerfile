################# Variables ################
ARG ELIXIR_VERSION=1.17.3
ARG OTP_VERSION=27.0.1
ARG DEBIAN_VERSION=bookworm-20250630-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

# Install build dependencies
RUN apt-get update -y && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y pkg-config openssl build-essential git nodejs && \
    apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /build_space

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV - ARG provides default, can be overridden by build-arg
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

ENV OTPROOT=/usr/lib/erlang
ENV ERL_LIBS=/usr/lib/erlang/lib

# copy umbrella configuration (copy all config files to support different environments)
COPY mix.exs mix.lock ./
COPY config/ config/

# copy umbrella apps
COPY apps/basic_app apps/basic_app/
COPY apps/basic_app_web apps/basic_app_web/

# install mix dependencies
RUN MIX_ENV="${MIX_ENV}" mix do deps.get --only "${MIX_ENV}", deps.compile

# Build assets (no npm needed - using esbuild directly)
RUN MIX_ENV="${MIX_ENV}" mix assets.setup
RUN MIX_ENV="${MIX_ENV}" mix assets.deploy

# compile project and build release
RUN MIX_ENV="${MIX_ENV}" mix compile && \
    MIX_ENV="${MIX_ENV}" mix release basic_app

########### RUNTIME ###############
# prepare release image
FROM ${RUNNER_IMAGE} AS basic_app

# Pass MIX_ENV to runtime stage
ARG MIX_ENV=prod

RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates libc6 curl && \
  apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

# Create directories
RUN mkdir -p /app/data

# Set ownership
RUN chown nobody /app
RUN chown nobody /app/data

# Copy release from builder (use MIX_ENV in path)
COPY --from=builder --chown=nobody /build_space/_build/${MIX_ENV}/rel/basic_app .

USER nobody

ENV HOME=/app
ENV MIX_ENV="${MIX_ENV}"

# Default environment variables
ENV SECRET_KEY_BASE="changeme"
ENV PORT="4000"

EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:4000/health || exit 1

ENTRYPOINT ["/app/bin/basic_app"]
CMD ["start"]
