defmodule Conc do

  @moduledoc """
  This is largely a direct transliteration from

  Organizing Function Code for Parallel Execution by Guy Steele
  https://vimeo.com/6624203

  The largest change is the standardization of the list as the first argument
  to most functions following in the Elixir style.
  """

  ## Primatives
  #############
  def null?([]), do: true
  def null?(_), do: false

  def singleton?([_]), do: true
  def singleton?(_), do: false

  def item([x]), do: x

  # this is necessary because `[x]` is in fact `[x | []]` and we don't want to
  # treat that as having a real left
  def left([left | right]) when right != [], do: left

  def right([_ | right]) when right != [], do: right

  def split([left | right], fun) do
    fun.(left, right)
  end

  def conc(left, right), do: [left | right]

  ## Basics
  #####################

  def first([]), do: []
  def first([x]), do: x
  def first(xs) do
    split(xs, fn ys, _ -> first(ys) end)
  end

  def rest([]), do: []
  def rest([_]), do: []
  def rest(xs) do
    split(xs, fn ys, zs ->
      ys
      |> rest
      |> append(zs)
    end)
  end

  def append([], ys), do: ys
  def append(xs, []), do: xs
  def append(xs, ys), do: rebalance [xs | ys]

  def add_left(xs, x), do: append([x], xs)
  def add_right(xs, x), do: append(xs, [x])

  def from_list([]), do: []
  def from_list([x]), do: [x]
  def from_list(list) do
    list
  end

  ## Fun Stuff
  #####################

  def map_reduce([], id, _, _), do: id
  def map_reduce([x], _, f, _), do: f.(x)
  def map_reduce(xs, id, f, g) do
    split(xs, &g.(map_reduce(&1, id, f, g), map_reduce(&2, id, f, g)))
  end

  def map(xs, f) do
    map_reduce(xs, [], &[f.(&1)], &append/2)
  end

  def reduce(xs, id, g) do
    map_reduce(xs, id, &(&1), g)
  end

  def length(xs) do
    map_reduce(xs, 0, fn _ -> 1 end, &(&1 + &2))
  end

  def filter(xs, p) do
    map_reduce(xs, [], fn x ->
      if p.(x), do: [x], else: []
    end,
    &append/2)
  end

  ## Utilities


  def rebalance(xs), do: xs

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
    ]

    opts = [strategy: :one_for_one, name: Conc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
