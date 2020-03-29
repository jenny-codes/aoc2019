defmodule Spaceship.Component.Amplifier do
  use GenServer, restart: :transient

  # ----------------------------------------------
  # Client API

  @doc """
  Initialize the amplifier.
  """
  def start_link(opts \\ []) do
    inbox =
      if is_list(opts[:inbox]) do
        opts[:inbox]
      else
        []
      end

    GenServer.start_link(__MODULE__, inbox, opts)
  end

  @doc """
  Send a signal to the server, to be stored in the "inbox".
  """
  def send_signal(server, signal) do
    GenServer.cast(server, {:send_signal, signal})
  end

  @doc """
  Pop a signal from inbox if any; return :no_signal if not.
  """
  def check_signal(server) do
    GenServer.call(server, :check_signal)
  end

  # ----------------------------------------------
  # GenServer Callbacks

  @impl true
  def init(inbox) when is_list(inbox) do
    {:ok, inbox}
  end

  @impl true
  def handle_call(:check_signal, _from, [signal | tail]) do
    {:reply, signal, tail}
  end

  @impl true
  def handle_call(:check_signal, _from, []) do
    {:reply, :no_signal, []}
  end

  @impl true
  def handle_cast({:send_signal, signal}, state) do
    {:noreply, state ++ [signal]}
  end

  @impl true
  def handle_cast({:run, program_str}, state) do
    ret_value = program_str
    |> Spaceship.Component.IntcodeMachine.build_program()
    |> Spaceship.Component.IntcodeMachine.execute(%{use_signal: true})

    {:noreply, state}
  end
end
