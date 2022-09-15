defmodule Server.TheCreator do
  import Plug.Conn

  defmacro __using__(_opts) do
    quote do
      import Server.TheCreator
      # Store the function assigned to the paths
      @paths []

      @error {}

      @before_compile Server.TheCreator
    end
  end

  defmacro my_get(path, do: block) do
    name = String.to_atom(path)
    quote do
      @paths [unquote(name) | @paths]
      def unquote(name)(), do: unquote(block)
    end
  end

  defmacro my_error(code: code, content: content) do
    quote do
      @error {unquote(code), unquote(content)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def init(opts), do: opts
      def call(%Plug.Conn{request_path: path} = conn, _opts) do
        name = String.to_atom(path)
        {code, description} = if Enum.member?(@paths, name), do: apply(__MODULE__, name, []), else: @error
        send_resp(conn, code, description)
#        case Enum.member?(@paths, name) do
#          true -> apply(__MODULE__, name, [conn])
#          false -> @error
#        end
      end
    end
  end
end
