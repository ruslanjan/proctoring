FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod

ENV DATABASE_URL=postgres://postgres:postgres@db:5432/proctoring
ENV SECRET_KEY_BASE=Q/395WH64Ld+IbUCiTngx3NOSfsLriD5K75mLajCIj+/mQLsC1QFGfviImzXzhOV

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
