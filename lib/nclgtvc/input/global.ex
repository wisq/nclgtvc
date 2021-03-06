defmodule NcLGTVc.Input.Global do
  require Logger
  alias NcLGTVc.{Console, Connection}

  def handle_key(?q) do
    Console.shutdown()
  end

  # def handle_key(?c) do
  #  Logger.warn("deliberately crashing now")
  #  raise "crash!"
  # end

  # def handle_key(?p) do
  #  IO.puts("I'm a bad boy, corrupting the screen")
  # end

  def handle_key(?[) do
    Connection.command("ssap://audio/volumeDown")
  end

  def handle_key(?]) do
    Connection.command("ssap://audio/volumeUp")
  end

  def handle_key(:up), do: Connection.button("UP")
  def handle_key(:down), do: Connection.button("DOWN")
  def handle_key(:left), do: Connection.button("LEFT")
  def handle_key(:right), do: Connection.button("RIGHT")
  def handle_key(?\n), do: Connection.click()

  # Control-L, redraw screen.
  def handle_key(12) do
    Console.redraw()
  end

  def handle_key(:resize) do
    Console.resize()
    Logger.info("resize to #{ExNcurses.lines()}x#{ExNcurses.cols()}")
  end

  def handle_key(key) do
    Logger.warn("Unknown key: #{inspect(key)}")
  end
end
