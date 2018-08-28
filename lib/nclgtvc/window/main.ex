defmodule NcLGTVc.Window.Main do
  use GenServer

  defmodule State do
    @enforce_keys [:windows, :current_window]
    defstruct(
      windows: %{},
      current_window: nil
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
    windows =
      %{}
      |> add_window(:log, NcLGTVc.Window.Main.Log)

    state = %State{
      windows: windows,
      current_window: Map.fetch!(windows, :log)
    }

    {:ok, state}
  end

  defp add_window(map, name, module) do
    {:ok, pid} = module.start_link()
    Map.put(map, name, {module, pid})
  end

  @impl true
  def handle_call({:resize, lines, columns}, _from, state) do
    Enum.each(state.windows, fn {_name, {module, pid}} ->
      module.resize_window(pid, lines, columns)
    end)

    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:refresh, _from, state) do
    {module, pid} = state.current_window
    module.refresh_window(pid)
    {:reply, :ok, state}
  end
end
