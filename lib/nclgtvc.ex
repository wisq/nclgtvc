defmodule NcLGTVc do
  use Application

  def hello do
    :world
  end

  def start(_type, _args) do
    NcLGTVc.Console.start_link()
  end
end
