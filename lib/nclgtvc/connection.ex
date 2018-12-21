defmodule NcLGTVc.Connection do
  use GenServer
  # require Logger
  alias ExLgtv.Client

  defmodule State do
    @enforce_keys [:host]
    defstruct(
      host: nil,
      client: nil,
      ready: false
    )
  end

  @name :nclgtvc_connection

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: @name)
  end

  @impl true
  def init(options) do
    Process.send_after(self(), :connect, 500)
    {:ok, %State{host: options.host}}
  end

  @impl true
  def handle_info(:connect, state) do
    {:ok, pid} = Client.start_link(state.host)
    {:noreply, %State{state | client: pid}}
  end
end