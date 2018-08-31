defmodule NcLGTVc.CLI do
  require Logger

  @nif_path Path.join(
              Mix.Project.build_path(),
              "lib/ex_ncurses/priv/ex_ncurses"
            )

  def main(args \\ []) do
    Application.put_env(:ex_ncurses, :nif_path, @nif_path)

    NcLGTVc.Options.parse(args)
    |> launch()
  end

  defp launch({:ok, _options}) do
    {:ok, pid} = NcLGTVc.Console.start_link()
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
