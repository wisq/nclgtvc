defmodule NcLGTVc.CLI do
  require Logger
  alias NcLGTVc.{Console, Options, Connection}

  @nif_path Path.join(
              Mix.Project.build_path(),
              "lib/ex_ncurses/priv/ex_ncurses"
            )

  def main(args \\ []) do
    Application.put_env(:ex_ncurses, :nif_path, @nif_path)

    Options.parse(args)
    |> launch()
  end

  defp launch({:ok, options}) do
    {:ok, _pid} = Connection.start_link(options)

    {:ok, pid} = Console.start_link()
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, :process, ^pid, :normal} -> :ok
      {:DOWN, ^ref, :process, ^pid, other} -> abort()
    end
  end

  defp launch({:error, messages}) do
    Enum.each(messages, &Logger.error/1)
    abort()
  end

  defp abort do
    Logger.flush()
    System.halt(1)
  end
end
