defmodule MyGenericServer do

  def start_link(callback_module, server_initial_state) do
    {:ok, spawn_link(fn -> loop(callback_module, server_initial_state) end)}
  end

  def loop(callback_module, server_state) do
    receive do
      {:call, request, pid} ->
        {amount, _} = callback_module.handle_call(request, server_state)
        loop(callback_module, send(pid, amount))
      {:cast, request} ->
        loop(callback_module, callback_module.handle_cast(request, server_state))
    end
  end

  def cast(process_pid, request) do
    send(process_pid, {:cast, request})
  end

  def call(process_pid, request) do
    send(process_pid, {:call, request, self()})
    receive do
      value -> value
    end

  end

end
