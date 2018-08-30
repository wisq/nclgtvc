defmodule NcLGTVc.Input.Global do
  require Logger

  def handle_key(?q) do
    # I should use System.stop(0) here and have proper cleanups
    # in the app, but for some reason, it takes 2+ seconds to exit,
    # and that just seems silly.
    #
    # Instead, let's just forcibly shut down.  It's not like we
    # have anything that needs cleaning up, AFAIK.
    # ExNcurses.endwin()
    # System.halt(0)
    # never returns
    NcLGTVc.Console.shutdown()
  end

  def handle_key(?c) do
    Logger.warn("deliberately crashing now")
    raise "crash!"
  end

  def handle_key(?p) do
    IO.puts("I'm a bad boy, corrupting the screen")
  end

  # Control-L, redraw screen.
  def handle_key(12) do
    NcLGTVc.Console.redraw()
  end

  def handle_key(:resize) do
    NcLGTVc.Console.resize()
    Logger.info("resize to #{ExNcurses.lines()}x#{ExNcurses.cols()}")
  end

  def handle_key(key) do
    Logger.warn("Unknown key: #{inspect(key)}")
  end
end
