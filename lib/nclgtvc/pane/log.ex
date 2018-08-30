defmodule NcLGTVc.Pane.Log do
  use GenServer
  require Logger
  alias NcLGTVc.Console
  alias NcLGTVc.Window.Main

  defmodule State do
    @enforce_keys [:nc_win]
    defstruct(
      nc_win: nil,
      messages: []
    )
  end

  @server_name :nclgtvc_pane_log

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: @server_name)
  end

  def resize(pid, lines, columns) do
    GenServer.call(pid, {:resize, lines, columns})
  end

  def refresh(pid) do
    GenServer.call(pid, :refresh)
  end

  def redraw(pid) do
    GenServer.call(pid, :redraw)
  end

  def add_message(msg) do
    case Process.whereis(@server_name) do
      nil -> {:error, :not_running}
      pid -> GenServer.call(pid, {:message, msg})
    end
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
    ExNcurses.scrollok(state.nc_win, true)
    do_redraw(state)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:refresh, _from, state) do
    ExNcurses.wnoutrefresh(state.nc_win)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:redraw, _from, state) do
    do_redraw(state)
    ExNcurses.wnoutrefresh(state.nc_win)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:message, msg}, _from, state) do
    ExNcurses.waddstr(state.nc_win, " #{msg}\n")
    ExNcurses.wborder(state.nc_win)
    Console.refresh(Main.window_name())

    messages = [msg | state.messages]
    state = %State{state | messages: messages}
    {:reply, :ok, state}
  end

  defp do_redraw(state) do
    content =
      state.messages
      |> Enum.reverse()
      |> Enum.map(&" #{&1}\n")
      |> Enum.join()

    ExNcurses.wclear(state.nc_win)
    ExNcurses.wmove(state.nc_win, 2, 0)
    ExNcurses.waddstr(state.nc_win, content)
    ExNcurses.wborder(state.nc_win)
  end
end
