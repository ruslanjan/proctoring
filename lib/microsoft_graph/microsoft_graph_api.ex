defmodule Proctoring.MicrosoftGraphApiServer do
  use GenServer

  @tenant "70c1157a-941c-4b39-98e6-a0634f2759e7"
  @client_id "90bc6e86-f550-44d3-9c53-c031410407c5"
  @client_secret "m~9iJ_4OUx~oPYxk59.yImZPEg7Y1~5C_3"
  @interval 600

  @impl true
  def init(_) do
    {:ok, %{
      last_update: DateTime.utc_now(),
      api_token: fetch_api_token()["access_token"]
    }}
  end

  @url "https://login.microsoftonline.com/" <> @tenant <> "/oauth2/v2.0/token"
  def fetch_api_token() do
    Jason.decode! HTTPoison.post!(@url, {:multipart, [
      {"client_id", @client_id},
      {"scope", "https://graph.microsoft.com/.default"},
      {"client_secret", @client_secret},
      {"grant_type", "client_credentials"}
    ]}).body
  end

  @url "https://login.microsoftonline.com/" <> @tenant <> "/discovery/v2.0/keys"
  def fetch_jwks() do
    (Jason.decode! HTTPoison.get!(@url).body)
  end
end
