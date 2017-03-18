FROM elixir
MAINTAINER https://github.com/JesusTinoco

WORKDIR /the_chicken
COPY . /the_chicken
RUN mix local.hex --force && mix deps.get && mix release.init && mix release

CMD ["_build/dev/rel/the_chicken/bin/the_chicken", "foreground"]
