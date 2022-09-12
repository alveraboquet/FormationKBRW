defmodule Server.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/read/*params" do
    conn = fetch_query_params(conn, [])
    case conn.query_params do
      %{"key" => key} ->
        res = Server.Database.read(:database, key)
        case res do
          [] -> send_resp(conn, 200, Poison.encode!(res))
          [{_res, value}] -> send_resp(conn, 200, Poison.encode!(value))
        end
      _ -> send_resp(conn, 401, "Bad request.")
    end
  end

  get "/create/*params" do
    conn = fetch_query_params(conn, [])
    case conn.query_params do
      %{"key" => key, "value" => value} ->
        send_resp(conn, 200, to_string(Server.Database.create(:database, key, value)))
      _ -> send_resp(conn, 401, "Bad request.")
    end
  end

  get "/update/*params" do
    conn = fetch_query_params(conn, [])
    case conn.query_params do
      %{"key" => key, "value" => value} ->
        send_resp(conn, 200, to_string(Server.Database.update(:database, key, value)))
      _ -> send_resp(conn, 401, "Bad request.")
    end
  end

  get "/delete/*params" do
    conn = fetch_query_params(conn, [])
    case conn.query_params do
      %{"key" => key} -> send_resp(conn, 200, to_string(Server.Database.delete(:database, key)))
      _ -> send_resp(conn, 401, "Bad request.")
    end
  end

  get "/search/*params" do
    conn = fetch_query_params(conn, [])
    {_, res} = Server.Database.search(:database,
      Enum.map(conn.query_params, fn {key, value} -> {key, value} end)
    )
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(res))
  end

  match _, do: send_resp(conn, 404, "Page Not Found")

  # use Server.TheCreator

  # my_error code: 404, content: "Custom error jkewnweklfj"

  # my_get "/" do
  #   {200, "Welcome to the new world of!"}
  # end

  # my_get "/me" do
  #   {200, "You are the Second One."}
  # end
end
