defmodule Solution do
  @moduledoc """
  Documentation for `Solution`.
  """

  use GenServer
  require Logger

  def run() do
    GenServer.call(__MODULE__, :run)
  end

  def info() do
    GenServer.call(__MODULE__, :info)
  end

  def start() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_params) do
    state = %{pricelist: build_prices(), shots_left: 100_000, res: nil, overflow: nil, quintil_amount: 5}
    {:ok, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end
  
  # TODO: make this one recursive so i can shorten the sub arrays
  # eg: depth 2 => 1 tops / x subs
  def handle_call(:run, _from, state) do

    res = 
      state.pricelist
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] -> a - b end)
      |> Enum.sort(:desc)

    quintil_size = div(length(res), state.quintil_amount)
    quintile = Enum.chunk_every(res, quintil_size)

    total_divide_factor = Enum.sum(Enum.to_list(1..state.quintil_amount))

    shots_per_factor = state.shots_left/total_divide_factor


    shots_per_quantil = 
      Enum.to_list(1..state.quintil_amount)
      |> Enum.map(&(&1*shots_per_factor))
      |> Enum.map(&(%{shots_left: trunc(&1)}))

    overflow = case List.last(quintile) do
      [] -> nil
      value -> value
    end

    {:reply,shots_per_quantil, %{state | res: res, overflow: overflow}}
  end


  defp build_prices() do
    Enum.to_list(1..100)
    |> Enum.map(fn x -> Kernel.trunc(:rand.uniform()*x)+2 end)
    |> Enum.sort(:desc)
  end

  
end
