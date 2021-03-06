defmodule Spaceship.Server.Amplifier do
  use GenServer, restart: :transient
  # TODO: if Amplifier should be refactored into Program?
  # because Amplifier is just one kind of program...
  # TODO: properly exit the process when finished.

  # ----------------------------------------------
  # Client API

  @doc """
  Initialize the amplifier.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      %{inbox: opts[:inbox] || [], task_ref: nil, task_status: nil},
      opts
    )
  end

  @doc """
  Send a signal to the server, to be stored in the "inbox".
  """
  def send_signal(server, signal) do
    GenServer.call(server, {:send_signal, signal})
  end

  @doc """
  Pop a signal from inbox if any; return :no_signal if not.
  """
  def check_signal(server) do
    GenServer.call(server, :check_signal)
  end

  @doc """
  Run the given program_str on IntcodeMachine.
  TODO: use Machine protocol and make IncodeMachine an argument (explicit contract)
  So that it will be run(server, program_str, machine, opts)
  """
  def run(server, program_str, opts) do
    GenServer.call(server, {:run, program_str, opts})
  end

  def check_result(server) do
    GenServer.call(server, :check_result)
  end

  # ----------------------------------------------
  # GenServer Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:check_signal, _from, %{inbox: inbox} = state) do
    case inbox do
      [signal | tail] -> {:reply, signal, %{state | inbox: tail}}
      [] -> {:reply, :no_signal, state}
    end
  end

  @impl true
  def handle_call({:send_signal, signal}, _from, %{task_status: :finished} = state) do
    IO.puts("[debug] final signal: #{signal}")
    {:reply, :ok, %{state | inbox: [signal]}}
  end

  @impl true
  def handle_call({:send_signal, signal}, _from, %{inbox: inbox} = state) do
    {:reply, :ok, %{state | inbox: inbox ++ [signal]}}
  end

  @impl true
  def handle_call({:run, program_str, opts}, _from, state) do
    task = run_program_in_task(program_str, opts)

    {:reply, :ok, Map.put(state, :task_ref, task.ref)}
  end

  def handle_call(:check_result, _from, %{task_status: :finished} = state) do
    {:reply, :finished, state}
  end

  @impl true
  def handle_call(:check_result, _from, state) do
    {:reply, :no_result, state}
  end

  @impl true
  def handle_info({task_ref, :ok}, %{task_ref: task_ref} = state) do
    # We don't care about the DOWN message now, so we demonitor and flush it
    Process.demonitor(task_ref, [:flush])
    {:noreply, %{state | task_status: :finished}}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, reason}, %{task_ref: ref} = state) do
    IO.inspect(reason, label: "A task down: ")
    {:noreply, %{state | ref: nil, task_status: :error}}
  end

  def run_program_in_task(program_str, opts) do
    program = Spaceship.Component.IntcodeMachine.build_program(program_str)

    Task.Supervisor.async_nolink(
      Spaceship.RunProgramTaskSupervisor,
      Spaceship.Component.IntcodeMachine,
      :execute,
      [program, opts]
    )
  end
end
