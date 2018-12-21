defmodule NcLGTVc.Connection do
  use GenServer
  require Logger
  alias ExLgtv.Client

  defmodule State do
    @enforce_keys [:host]
    defstruct(
      host: nil,
      client: nil
    )
  end

  @name :nclgtvc_connection

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: @name)
  end

  def command(uri, payload \\ %{}) do
    GenServer.call(@name, {:command, uri, payload})
  end

  def button(button) do
    GenServer.call(@name, {:button, button})
  end

  def click do
    GenServer.call(@name, :click)
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

  defp try_call(state, action, fun) do
    if state.client do
      {:reply, fun.(), state}
    else
      Logger.warn("Not connected; can't #{action}.")
      {:reply, {:error, :not_connected}, state}
    end
  end

  @impl true
  def handle_call({:command, uri, payload}, _from, state) do
    try_call(state, "execute command", fn ->
      Client.command(state.client, uri, payload)
    end)
  end

  @impl true
  def handle_call({:button, button}, _from, state) do
    try_call(state, "press #{button}", fn ->
      Client.button(state.client, button)
    end)
  end

  @impl true
  def handle_call(:click, _from, state) do
    try_call(state, "click", fn ->
      Client.click(state.client)
    end)
  end
end
