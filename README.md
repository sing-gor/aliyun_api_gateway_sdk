# AliyunApiGatewaySdk

AliyunApiGatewaySdk is based on [Tesla](https://hexdocs.pm/tesla/readme.html)  
It can simple call an api from Alibaba API Gateway by using an AppCode

## Getting started
Add the following to config/config.exs:
```elixir
config :my_app, :aliyun_api_gateway_sdk,
        HOST: "<HOST>",
        API_APP_KEY: "<YOUR API_APP_KEY>",
        API_APP_SECRET: "<YOUR API_APP_SECRET>",
        API_ENV: "<YOUR API_ENV>"
```

## Perform a GET request
```elixir
# get/1
AliyunApiGatewaySdk.get("/api/doc")

# get/2
query = %{"id" => "1"}
AliyunApiGatewaySdk.get("/api/doc", query)

# get/3
query = %{"id" => "1"}
header = %{"Authorization" => "JWT <YOUR TOKEN>"}
AliyunApiGatewaySdk.get("/api/doc", query, header)

# get/3
# If no need query ,just need header
query = %{}
header = %{"Authorization" => "JWT <YOUR TOKEN>"}
AliyunApiGatewaySdk.get("/api/doc", query, header)

```

## Perform a POST request
```elixir
# post/1
AliyunApiGatewaySdk.post("/api/doc")

# post/2
body = %{"username" => "root", "password" => "root"}
AliyunApiGatewaySdk.post("/api/login", body)

# post/3
body = %{"title" => "My Programming Motto", "body" => "Programming is thinking, not typding"}
header = %{"Authorization" => "JWT <YOUR TOKEN>"}
AliyunApiGatewaySdk.post("/api/doc/articles", body, header)

# post/3
# If no need body, just need header 
body = %{}
header = %{"Authorization" => "JWT <YOUR TOKEN>"}
AliyunApiGatewaySdk.post("/api/doc", body, header)

```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `aliyun_api_gateway_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:aliyun_api_gateway_sdk, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/aliyun_api_gateway_sdk>.
