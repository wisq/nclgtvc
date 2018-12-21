defmodule NcLGTVc.Input.Global do
  require Logger

  def handle_key(?q) do
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
