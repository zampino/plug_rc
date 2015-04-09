defmodule PlugRc.Server do

  def start_link do
   port = String.to_integer System.get_env["PORT"] || "4000"
   Plug.Adapters.Elli.http PlugRc.Router, [], port: port
 end

end
