defmodule NcLGTVc.MixProject do
  use Mix.Project

  def project do
    [
      app: :nclgtvc,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp escript do
    [
      main_module: NcLGTVc.CLI,
      emu_args: "-noinput"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:ex_lgtv, path: "../ex_lgtv"},
      {:ex_ncurses, path: "../ex_ncurses"},
      {:logger_file_backend, "~> 0.0.10"}
    ]
  end
end
