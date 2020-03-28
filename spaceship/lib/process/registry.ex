defmodule Spaceship.Registry do
  use GenServer

  ## Defining client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Defining GenServer Callbacks

  @impl true
  @spec init(:ok) :: {:ok, {%{}, %{}}}
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_cast({:create, name}, state) do
    {names, refs} = state

    if Map.has_key?(names, name) do
      {:noreply, state}
    else
      {:ok, pid} = DynamicSupervisor.start_child(Spaceship.BucketSupervisor, Spaceship.Bucket)
      ref = Process.monitor(pid)
      new_refs = Map.put(refs, ref, name)
      new_names = Map.put(names, name, pid)
      # returning a new server state
      {:noreply, {new_names, new_refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {names, refs} = state
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
