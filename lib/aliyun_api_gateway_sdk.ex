defmodule AliyunApiGatewaySdk do
  @moduledoc """
  # Getting Started

  Add the following to config/config.exs:

    config :my_app, :aliyun_api_gateway_sdk,
      HOST: "<HOST>",
      API_APP_KEY: "<YOUR API_APP_KEY>",
      API_APP_SECRET: "<YOUR API_APP_SECRET>",
      API_ENV: "<YOUR API_ENV>"


  """

  @doc """
  iex> AliyunApiGatewaySdk.get('/api/doc/')
  """
  @spec get(String.t()) :: Tesla.Env.result()
  def get(path) do
    aliyun_api_request("GET", path, %{}, %{}, get_config())
  end

  @doc """

  """
  @spec get(String.t(), Map.t()) :: Tesla.Env.result()
  def get(path, body) do
    aliyun_api_request("GET", path, %{}, body, get_config())
  end

  @doc """

  """
  @spec get(String.t(), Map.t(), Map.t()) :: Tesla.Env.result()
  def get(path, body, header) do
    aliyun_api_request("GET", path, header, body, get_config())
  end

  @doc """

  """
  @spec post(String.t()) :: Tesla.Env.result()
  def post(path) do
    aliyun_api_request("POST", path, %{}, %{}, get_config())
  end

  @doc """

  """
  @spec post(String.t(), Map.t()) :: Tesla.Env.result()
  def post(path, body) do
    aliyun_api_request("POST", path, %{}, body, get_config())
  end

  @doc """

  """
  @spec post(String.t(), Map.t(), Map.t()) :: Tesla.Env.result()
  def post(path, body, header) do
    aliyun_api_request("POST", path, header, body, get_config())
  end

  @doc """
  Call An API

  That is base request call, you can set your special signature method

  ## Parameters

    - method: String that represents the method of the request.
    - path: String that represents the path of the request.
    - base_header: Map that represents the header of the request.
    - body: Map that represents the body of the request.
    - req_data: Map that represents the host app_key api_env and app_secre of the request.

  ## Examples
      # test
      iex> method = "get"
      "get"

      iex> path = "/test/"
      "/test/"

      iex> header = %{"Authorization" => "JWT <YOUR TOKEN>"}
      %{"Authorization" => "JWT <YOUR TOKEN>"}

      iex> body = %{"id" => "1"}
      %{"id" => "1"}

      iex>req_data = %{"HOST" => "<HOST>","API_APP_KEY" => "<YOUR APP_KEY>","API_ENV" => "<ENV: RELEASE / TEST / PRO >","API_APP_SECRET" => "<YOUR APP_SECRET>"}
      %{
       "API_APP_KEY" => "<YOUR APP_KEY>",
       "API_APP_SECRET" => "<YOUR APP_SECRET>",
       "API_ENV" => "<ENV: RELEASE / TEST / PRO >",
       "HOST" => "<HOST>"
      }

      iex> aliyun_api_request(method, path, base_header, body, req_data)
      {:ok,
        %{
        body: "{\"data\": 1}",
        headers: [
        {"connection", "keep-alive"},
        {"date", "Sum, 22 Jan 2023 06:57:23 GMT"},
        {"content-length", "575"},
        {"content-type", "application/json;charset=utf-8"},
        {"access-control-allow-origin", "*"},
          ]
        }
      }

  """
  @spec aliyun_api_request(String.t(), String.t(), Map.t(), Map.t(), Map.t()) ::
          Tesla.Env.result()
  def aliyun_api_request(method, path, base_header, body, req_data) do
    client(method, path, base_header, body, req_data)
    |> api_request(String.upcase(method), path, body)
    |> case do
      {:ok, %{status: 200, body: body, headers: headers}} ->
        {:ok, %{:body => body, :headers => headers}}

      {:ok, %{status: status}} ->
        {:error, status}

      other ->
        other
    end
  end

  defp api_request(client, "POST", path, body) do
    Tesla.post(client, path, body)
  end

  defp api_request(client, "GET", path, body) when map_size(body) == 0 do
    Tesla.get(client, path)
  end

  defp api_request(client, "GET", path, body) do
    Tesla.get(client, "#{path}?#{URI.encode_query(body)}")
  end

  def client(method, path, base_header, body, req_data) do
    header = gen_header(method, path, base_header, body, req_data)

    middleware = [
      {Tesla.Middleware.BaseUrl, req_data["HOST"]},
      {Tesla.Middleware.Headers, header},
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.Logger
    ]

    Tesla.client(middleware)
  end

  def gen_sign_header_str(method, path, header, body, req_data) do
    data = ["#{String.upcase(method)}\n"]

    header_order_list = [
      "Accept",
      "Content-MD5",
      "Content-Type",
      "Date",
      "X-Ca-Key",
      "X-Ca-Stage",
      "X-Ca-Timestamp"
    ]

    data_list = Enum.map(header_order_list, fn x -> push_header_list(header, x) end)

    data
    |> List.flatten(data_list)
    |> gen_sign_path_str?(path, body)
    |> List.to_string()
    |> hmac_sha256(req_data["API_APP_SECRET"])
    |> Base.encode64()
  end

  def hmac_sha256(data, key) do
    :crypto.mac(:hmac, :sha256, key, data)
  end

  def push_header_list(header, key) do
    case {Map.fetch(header, key), String.starts_with?(key, "X-Ca-")} do
      {{:ok, value}, true} ->
        "#{key}:#{value}\n"

      {{:ok, value}, false} ->
        "#{value}\n"

      _ ->
        "\n"
    end
  end

  def gen_sign_path_str?(data, path, body) when map_size(body) == 0 do
    data ++ ["#{path}"]
  end

  def gen_sign_path_str?(data, path, body) when length(body) == 0 do
    data ++ ["#{path}"]
  end

  def gen_sign_path_str?(data, path, body) do
    query_str = URI.encode_query(body)

    data ++ ["#{path}?#{query_str}"]
  end

  def gen_base_header(header, req_data) do
    now_time = Calendar.DateTime.now_utc()

    header
    |> Map.put("X-Ca-Timestamp", Integer.to_string(Calendar.DateTime.Format.js_ms(now_time)))
    |> Map.put("Date", Calendar.DateTime.Format.httpdate(now_time) <> "+00:00")
    |> Map.put("X-Ca-Stage", req_data["API_ENV"])
    |> Map.put("X-Ca-Key", req_data["API_APP_KEY"])
    |> Map.put("Content-Type", "application/x-www-form-urlencoded")
    |> Map.put("Accept", "application/json; charset=utf-8")
  end

  def gen_header(method, path, base_header, body, req_data) do
    header = gen_base_header(base_header, req_data)
    sign = gen_sign_header_str(method, path, header, body, req_data)

    header_key = gen_ca_sign_header_str(header)

    header
    |> Map.put("X-Ca-Signature", sign)
    |> Map.put("X-Ca-Signature-Headers", header_key)
    |> Map.to_list()
  end

  def gen_ca_sign_header_str(data) do
    data
    |> Map.keys()
    |> Enum.filter(fn x -> String.starts_with?(x, "X-Ca-") end)
    |> Enum.join(",")
  end

  def get_config() do
    %{
      "API_APP_KEY" => Application.get_env(:aliyun_api_gateway_sdk, :API_APP_KEY),
      "API_APP_SECRET" => Application.get_env(:aliyun_api_gateway_sdk, :API_APP_SECRET),
      "API_ENV" => Application.get_env(:aliyun_api_gateway_sdk, :API_ENV),
      "HOST" => Application.get_env(:aliyun_api_gateway_sdk, :HOST)
    }
  end
end
