defmodule NcLGTVc.Window.Main do
  use GenServer

  defmodule State do
    @enforce_keys [:panes, :current_pane]
    defstruct(
      panes: %{},
      current_pane: nil
    )
  end

  @window :main
  def window_name(), do: @window

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def resize_window(pid, lines, columns) do
    GenServer.call(pid, {:resize, lines, columns})
  end

  def refresh_window(pid) do
    GenServer.call(pid, :refresh)
  end

  @impl true
  def init(nil) do
    panes =
      %{}
      |> add_pane(:log, NcLGTVc.Pane.Log)

    state = %State{
      panes: panes,
      current_pane: Map.fetch!(panes, :log)
    }

    {:ok, state}
  end

  defp add_pane(map, name, module) do
    {:ok, pid} = module.start_link()
    Map.put(map, name, {module, pid})
  end

  @impl true
  def handle_call({:resize, lines, columns}, _from, state) do
    Enum.each(state.panes, fn {_name, {module, pid}} ->
      module.resize(pid, lines, columns)
    end)

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:refresh, _from, state) do
    {module, pid} = state.current_pane
    module.refresh(pid)
    {:reply, :ok, state}
  end
end
