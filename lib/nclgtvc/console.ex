defmodule NcLGTVc.Console do
  use GenServer
  require Logger

  alias NcLGTVc.Input

  defmodule State do
    @enforce_keys [:windows]
    defstruct(windows: %{})
  end

  defmodule Window do
    @enforce_keys [:name, :module]
    defstruct(
      name: nil,
      module: nil,
      pid: nil,
      visible: true,
      above: [],
      below: []
    )
  end

  @name :nclgtvc_console

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: @name)
  end

  def shutdown do
    GenServer.cast(@name, :shutdown)
  end

  def refresh(window_name) do
    GenServer.cast(@name, {:refresh_one, window_name})
  end

  def redraw do
    GenServer.cast(@name, :redraw)
  end

  def resize do
    GenServer.cast(@name, :resize)
  end

  @impl true
  def init(nil) do
    Process.flag(:trap_exit, true)
    Logger.remove_backend(:console)
    ExNcurses.initscr()
    ExNcurses.noecho()
    ExNcurses.listen()

    windows =
      %{}
      |> add_window(NcLGTVc.Window.Main)

    state = %State{windows: windows}

    resize_all(windows)
    ExNcurses.doupdate()
    {:ok, state}
  end

  @impl true
  def handle_cast({:refresh_one, name}, state) do
    refresh_one(state.windows, name)
    ExNcurses.doupdate()
    {:noreply, state}
  end

  @impl true
  def handle_cast(:redraw, state) do
    touch_all(state.windows)
    ExNcurses.clear()
    refresh_all(state.windows)
    ExNcurses.doupdate()
    {:noreply, state}
  end

  @impl true
  def handle_cast(:resize, state) do
    resize_all(state.windows)
    ExNcurses.doupdate()
    {:noreply, state}
  end

  @impl true
  def handle_cast(:shutdown, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:ex_ncurses, :key, key}, state) do
    Input.Global.handle_key(key)
    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    ExNcurses.endwin()
    Logger.add_backend(:console)

    if reason == :normal do
      # Faster shutdown.  For some reason, stop() takes a couple of seconds.
      Logger.flush()
      System.halt(0)
    else
      Logger.error("Console exiting unexpectedly.")
      System.stop(0)
    end
  end

  defp add_window(map, module, opts \\ []) do
    name = module.window_name()
    {:ok, pid} = module.start_link()

    keys =
      Map.new(opts)
      |> Map.merge(%{
        name: name,
        module: module,
        pid: pid
      })

    window = struct!(Window, keys)
    Map.put(map, name, window)
  end

  defp resize_all(windows) do
    lines = ExNcurses.lines()
    columns = ExNcurses.cols()

    Enum.each(windows, fn {_, w} ->
      w.module.resize_window(w.pid, lines, columns)
    end)

    refresh_all(windows)
  end

  defp touch_all(windows) do
    windows
    |> Map.values()
    |> Enum.filter(& &1.visible)
    |> Enum.each(fn w ->
      w.module.touch_window(w.pid)
    end)
  end

  defp refresh_all(windows) do
    windows
    |> Map.values()
    |> Enum.filter(& &1.visible)
    |> Enum.sort(&sort_overlapping/2)
    |> Enum.each(fn w ->
      w.module.refresh_window(w.pid)
    end)
  end

  defp refresh_one(windows, name) do
    w = Map.fetch!(windows, name)

    if w.visible do
      w.module.refresh_window(w.pid)
    end

    # Render windows above this one.
    # This is outside the `if` so that deeply-nested windows
    # will work correctly (though we don't have any yet).
    Enum.each(w.below, &refresh_one(windows, &1))
  end

  # Return true if win1 should be drawn before win2,
  # i.e. if win1 is BELOW win2.
  defp sort_overlapping(win1, win2) do
    cond do
      Enum.member?(win1.below, win2.name) -> true
      Enum.member?(win2.above, win1.name) -> true
      true -> false
    end
  end
end
