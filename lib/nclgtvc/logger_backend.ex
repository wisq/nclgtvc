defmodule NcLGTVc.LoggerBackend do
  @behaviour :gen_event

  defmodule State do
    @enforce_keys [:name]
    defstruct(
      name: nil,
      buffer: :queue.new()
    )
  end

  @impl true
  def init(:nclgtvc = name) do
    {:ok, %State{name: name}}
  end

  @impl true
  def init({__MODULE__, name}) do
    {:ok, %State{name: name}}
  end

  @impl true
  def handle_call({:configure, _options}, state) do
    {:ok, state}
  end

  @impl true
  def handle_event({level, _gl, {Logger, msg, ts, md}}, state) do
    text = IO.iodata_to_binary(msg) |> String.trim()
    buffer = :queue.in(text, state.buffer) |> flush_buffer()
    {:ok, %State{state | buffer: buffer}}
  end

  @impl true
  def handle_event(:flush, state) do
    buffer = flush_buffer(state.buffer)
    {:ok, %State{state | buffer: buffer}}
  end

  @impl true
  def handle_info(:try_flush, state) do
    buffer = flush_buffer(state.buffer)
    {:ok, %State{state | buffer: buffer}}
  end

  @impl true
  def handle_info(_unknown, state) do
    {:ok, state}
  end

  defp flush_buffer(buffer) do
    case :queue.out(buffer) do
      {{:value, msg}, new_buffer} -> flush_buffer_message(msg, buffer, new_buffer)
      {:empty, _} -> buffer
    end
  end

  defp flush_buffer_message(msg, old_buffer, new_buffer) do
    case NcLGTVc.Pane.Log.add_message(msg) do
      :ok ->
        flush_buffer(new_buffer)

      {:error, :not_running} ->
        # Try again in 0.5 seconds.
        Process.send_after(self(), :try_flush, 500)
        # Keep the buffer as-is.
        old_buffer
    end
  end
end
