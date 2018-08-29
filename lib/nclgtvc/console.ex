defmodule NcLGTVc.Console do
  use GenServer

  defmodule State do
    @enforce_keys [:windows]
    defstruct(windows: %{})
  end

  defmodule Window do
    @enforce_keys [:module]
    defstruct(
      module: nil,
      pid: nil,
      visible: true,
      above: [],
      below: []
    )
  end

  @name :nclgtvc_console

  def child_spec do
    %{
      id: @name,
      start: {__MODULE__, :start_link, []},
      restart: :transient
    }
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: @name)
  end

  def refresh(window_name) do
    GenServer.cast(@name, {:refresh_one, window_name})
  end

  def refresh_all do
    GenServer.cast(@name, :refresh_all)
  end

  @impl true
  def init(nil) do
    ExNcurses.initscr()

    windows =
      %{}
      |> add_window(NcLGTVc.Window.Main)

    state = %State{windows: windows}

    resize_all(windows)
    {:ok, state}
  end

  @impl true
  def handle_cast({:refresh_one, name}, state) do
    refresh_one(state.windows, name)
    ExNcurses.doupdate()
    {:noreply, state}
  end

  defp add_window(map, module, opts \\ []) do
    {:ok, pid} = module.start_link()

    keys =
      Map.new(opts)
      |> Map.merge(%{
        module: module,
        pid: pid
      })

    name = module.window_name()
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
    ExNcurses.doupdate()
  end

  defp refresh_all(windows) do
    windows
    |> Enum.sort(&sort_overlapping/2)
    |> Enum.each(fn {_, w} ->
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
  defp sort_overlapping({name1, win1}, {name2, win2}) do
    cond do
      Enum.member?(win1.below, name2) -> true
      Enum.member?(win2.above, name1) -> true
      true -> false
    end
  end
end
