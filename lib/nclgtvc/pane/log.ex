defmodule NcLGTVc.Pane.Log do
  use GenServer

  defmodule State do
    @enforce_keys [:nc_win]
    defstruct(
      nc_win: nil,
      messages: [
        "this is a window",
        "it contains text",
        "more text here"
      ]
    )
  end

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def resize(pid, lines, columns) do
    GenServer.call(pid, {:resize, lines, columns})
  end

  def refresh(pid) do
    GenServer.call(pid, :refresh)
  end

  @impl true
  def init(nil) do
    nc_win = ExNcurses.newwin(0, 0, 0, 0)
    state = %State{nc_win: nc_win}
    {:ok, state}
  end

  @impl true
  def handle_call({:resize, lines, columns}, _from, state) do
    ExNcurses.wresize(state.nc_win, lines - 4, columns)
    ExNcurses.mvwin(state.nc_win, 2, 0)
    {:reply, :ok, state, {:continue, :redraw}}
  end

  @impl true
  def handle_call(:refresh, _from, state) do
    ExNcurses.wnoutrefresh(state.nc_win)
    {:reply, :ok, state}
  end

  @impl true
  def handle_continue(:redraw, state) do
    content =
      state.messages
      |> Enum.map(&" #{&1}")
      |> Enum.join("\n")

    ExNcurses.wmove(state.nc_win, 2, 0)
    ExNcurses.waddstr(state.nc_win, content)
    ExNcurses.wborder(state.nc_win)
    {:noreply, state}
  end
end
