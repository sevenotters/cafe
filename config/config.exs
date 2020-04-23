use Mix.Config

config :seven, Seven.Entities, entity_app: :cafe

#
# Mongo persistence
#
# config :seven,
#   persistence: SevenottersMongo.Storage

# config :seven, Seven.Data.Persistence,
#   database: "cafe",
#   hostname: "127.0.0.1",
#   port: 27_017

config :logger, :console,
  format: "$date-$time [$level] $message\n",
  level: :info

#
# Elasticsearch persistence
#
# config :seven,
#   persistence: SevenottersElasticsearch.Storage

# config :seven, Seven.Data.Persistence,
#   url: "http://localhost",
#   port: 9_200

# config :elastix,
#   json_options: [keys: :atoms],
#   httpoison_options: [hackney: [pool: :elastix_pool]]
