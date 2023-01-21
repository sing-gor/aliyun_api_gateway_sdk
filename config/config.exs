import Config

config :aliyun_api_gateway_sdk,
  HOST: "<HOST>",
  API_APP_KEY: "<YOUR API_APP_KEY>",
  API_APP_SECRET: "<YOUR API_APP_SECRET>",
  API_ENV: "<YOUR API_ENV>"

import_config "#{config_env()}.exs"
