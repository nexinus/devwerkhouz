# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.4
FROM ruby:${RUBY_VERSION}-slim AS base
WORKDIR /rails

# --- common runtime deps ---
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# -------- BUILD STAGE --------
FROM base AS build

# install build tools first
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config nodejs npm gnupg && \
    rm -rf /var/lib/apt/lists/*

# make sure we have the bundler version your Gemfile.lock expects
RUN gem install bundler -v 2.7.1

# copy only Gemfiles and install gems (leverage cache)
COPY Gemfile Gemfile.lock ./
RUN bundle _2.7.1_ install --jobs 4 --retry 3

# enable corepack & prepare yarn
RUN npm i -g corepack || true
RUN corepack enable || true
RUN corepack prepare yarn@stable --activate || true

# copy package files and install node deps
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# copy the rest of the app
COPY . .

# precompile bootsnap (optional but fine)
RUN bundle exec bootsnap precompile app/ lib/ || true

# generate temporary secret and precompile assets
# use ruby to generate a strong secret at build time
RUN SECRET=$(ruby -rsecurerandom -e 'print SecureRandom.hex(64)') && \
    SECRET_KEY_BASE=$SECRET RAILS_ENV=production bin/rails assets:precompile

# -------- FINAL IMAGE --------
FROM base

# copy gems and app from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# runtime user (non-root)
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails/tmp /rails/log /rails/storage

USER rails

WORKDIR /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80

# default command (use your existing thrust if you want)
CMD ["./bin/thrust", "./bin/rails", "server"]
