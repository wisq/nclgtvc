defmodule NcLGTVc.LoggerBackend do
  @behaviour :gen_event

  @impl true
  def init(:nclgtvc) do
    {:ok, nil}
  end

  @impl true
  def init({__MODULE__, _name}) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:configure, options} = msg, state) do
    NcLGTVc.Pane.Log.add_message(inspect(msg))
    {:ok, :ok, state}
  end

  @impl true
  def handle_event(event, state) do
    NcLGTVc.Pane.Log.add_message(inspect(event))
    {:ok, state}
  end

  # def handle_event({level, _gl, {Logger, msg, ts, md}} = msg, state) do
  #  IO.inspect(msg)
  # end
end
