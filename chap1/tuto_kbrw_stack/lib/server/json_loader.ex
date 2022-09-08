defmodule Server.JsonLoader do

  def load_to_database(database, json_file) do
    {:ok, file} = File.read(json_file)
    raw_data = Poison.decode!(file)
    data = Enum.map(raw_data, fn data -> Map.pop(data, "id") end)
    Enum.each(data, fn {key, value} -> Server.Database.write(database, key, value) end)
  end

end
