defmodule NcLGTVc.Pane.Log do
  use GenServer
  alias NcLGTVc.Console
  alias NcLGTVc.Window.Main

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
    Process.send_after(self(), {:message, 1}, 200)
    {:ok, state}
  end

  @impl true
  def handle_call({:resize, lines, columns}, _from, state) do
    ExNcurses.wresize(state.nc_win, lines - 4, columns)
    ExNcurses.mvwin(state.nc_win, 2, 0)
    ExNcurses.scrollok(state.nc_win, true)
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
      |> Enum.reverse()
      |> Enum.map(&" #{&1}\n")
      |> Enum.join()

    ExNcurses.wmove(state.nc_win, 2, 0)
    ExNcurses.waddstr(state.nc_win, content)
    ExNcurses.wborder(state.nc_win)
    {:noreply, state}
  end

  @impl true
  def handle_info({:message, n}, state) do
    msg = "message #{n}"
    ExNcurses.waddstr(state.nc_win, " #{msg}\n")
    ExNcurses.wborder(state.nc_win)
    Console.refresh(Main.window_name())

    messages = [msg | state.messages]
    state = %State{state | messages: messages}
    Process.send_after(self(), {:message, n + 1}, 200)
    {:noreply, state}
  end
end
