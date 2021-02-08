FROM bitwalker/alpine-elixir-phoenix:latest

RUN apt-get -qq update
RUN apt-get -qq install git build-essential
RUN apk add --no-cache build-base

# Set exposed ports
EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod

ARG DATABASE_URL=postgres://postgres:postgres@db:5432/proctoring
ARG SECRET_KEY_BASE=Q/395WH64Ld+IbUCiTngx3NOSfsLriD5K75mLajCIj+/mQLsC1QFGfviImzXzhOV
ENV DATABASE_URL=$DATABASE_URL
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

USER default

CMD ["mix", "phx.server"]
