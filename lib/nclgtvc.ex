defmodule NcLGTVc do
  use Application

  def hello do
    :world
  end

  def start(_type, _args) do
    children = [
      NcLGTVc.Console.child_spec()
    ]

    opts = [strategy: :one_for_one, name: NcLGTVc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
