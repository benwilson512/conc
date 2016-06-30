defmodule Conc do

  @moduledoc """
  This is largely a direct transliteration from

  Organizing Function Code for Parallel Execution by Guy Steele
  https://vimeo.com/6624203

  The largest change is the standardization of the list as the first argument
  to most functions following in the Elixir style.
  """

  ## Primitives
  #############

  @opaque conc_list :: maybe_improper_list

  @doc """
  Returns `true` if we have an empty Conc List, `false` for anything else.
  """
  @spec null?(conc_list) :: boolean
  def null?([]), do: true
  def null?(_), do: false

  @doc """
  Returns true if we have a Conc List with exactly one element, `false` for anything else.
  """
  @spec singleton?(conc_list) :: boolean
  def singleton?([_]), do: true
  def singleton?(_), do: false

  @doc """
  Returns the contents of a singleton Conc List.
  """
  @spec item(conc_list) :: boolean
  def item([x]), do: x

  @doc """
  Returns the left partition of the Conc List.
  """
  # The guard clause is necessary because `[x]` is in fact `[x | []]` and we don't want to
  # treat that as having a real left
  @spec left(conc_list) :: conc_list
  def left([left | right]) when right != [], do: left

  @doc """
  Returns the right partition of the Conc List.
  """
  @spec right(conc_list) :: conc_list
  def right([_ | right]) when right != [], do: right

  @doc """
  Splits the Conc List, and calls the function with `left` as first parameter, and `right` as second.

  This function is mostly useful to build higher-level abstractions on top of.
  """
  @spec split(conc_list, ((conc_list, conc_list) -> any)) :: any
  def split([left | right], fun) do
    fun.(left, right)
  end

  @doc """
  Builds a simple two-element Conc List
  """
  @spec conc(any, any) :: conc_list
  def conc(left, right), do: [left | right]

  ## Basics
  #####################

  @doc """
  Returns the first element of the Conc List.  
  
  TODO: Maybe throw error if empty Conc List?
  """
  @spec first(conc_list) :: any
  def first([]), do: []
  def first([x]), do: x
  def first(xs) do
    split(xs, fn ys, _ -> first(ys) end)
  end

  @doc """
  Returns anything but the first element of the Conc List.  
  
  TODO: Maybe throw error if empty Conc List?
  """
  @spec first(conc_list) :: any
  def rest([]), do: []
  def rest([_]), do: []
  def rest(xs) do
    split(xs, fn ys, zs ->
      ys
      |> rest
      |> append(zs)
    end)
  end

  @doc """
  Appends two Conc Lists together.
  """
  @spec append(conc_list, conc_list) :: conc_list
  def append([], ys), do: ys
  def append(xs, []), do: xs
  def append(xs, ys), do: rebalance [xs | ys]

  @doc """
  Adds a value to the leftmost side (the front) of the Conc List
  """
  @spec add_left(conc_list, any) :: conc_list
  def add_left(xs, x), do: append([x], xs)

  @doc """
  Adds a value to the leftmost side (the end) of the Conc List
  """
  @spec add_right(conc_list, any) :: conc_list
  def add_right(xs, x), do: append(xs, [x])

  @doc """
  Converts a List into a Conc List
  """
  @spec from_list(list) :: conc_list
  def from_list([]), do: []
  def from_list([x]), do: [x]
  def from_list(list) do
    list
  end

  ## Fun Stuff
  #####################

  @doc """
  Maps and Reduces the Conc List in one go.

  Takes a Conc List, a starting accumulator value, a function to map with, and a function that is used to reduce the results of this map.
  """
  @spec map_reduce(conc_list, any, (any -> any), ((any, any) -> any)) :: any
  def map_reduce([], id, _, _), do: id
  def map_reduce([x], _, mapping_fun, _), do: mapping_fun.(x)
  def map_reduce(xs, id, mapping_fun, reducing_fun) do
    split(xs, &reducing_fun.(map_reduce(&1, id, mapping_fun, reducing_fun), map_reduce(&2, id, mapping_fun, reducing_fun)))
  end

  @doc """
  Maps `fun` over each of the elements in the Conc List, and returns a new Conc List with the results. 
  """
  @spec map(conc_list, (any -> any)) :: conc_list
  def map(xs, fun) do
    map_reduce(xs, [], &[fun.(&1)], &append/2)
  end

  @spec reduce(conc_list, any, (any -> any)) :: any
  def reduce(xs, id, g) do
    map_reduce(xs, id, &(&1), g)
  end

  @spec length(conc_list) :: integer
  def length(xs) do
    map_reduce(xs, 0, fn _ -> 1 end, &(&1 + &2))
  end

  @spec filter(conc_list, (any -> as_boolean(any))) :: conc_list
  def filter(xs, p) do
    map_reduce(xs, [], fn x ->
      if p.(x), do: [x], else: []
    end,
    &append/2)
  end

  ## Utilities

  @doc """
  Rebalances the Conc List so all elements can be accessed with about similar efficiency.
  """
  @spec rebalance(conc_list) :: conc_list
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
