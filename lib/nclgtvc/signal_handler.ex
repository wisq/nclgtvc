defmodule NcLGTVc.SignalHandler do
  use System.SignalHandler
  require Logger

  handle :winch do
    Logger.info("#{ExNcurses.lines()} #{ExNcurses.cols()}")
    NcLGTVc.Console.resize()
  end
end
