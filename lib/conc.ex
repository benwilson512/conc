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

  @type conc_list :: maybe_improper_list

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
  Combines two Conc Lists into one.
  """
  @spec conc(conc_list, conc_list) :: conc_list
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
  @spec rest(conc_list) :: any
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
  @spec map_reduce(conc_list, c, (a -> b), ((b, c) -> c)) :: b when a: any, b: any, c: any
  def map_reduce(xs, id, mapping_fun, reducing_fun)

  def map_reduce([], id, _, _), do: id
  def map_reduce([x], _, mapping_fun, _), do: mapping_fun.(x)
  def map_reduce(xs, id, mapping_fun, reducing_fun) do
    IO.puts "map_reduce called with #{inspect xs}"
    split(xs, &reducing_fun.(map_reduce(&1, id, mapping_fun, reducing_fun), map_reduce(&2, id, mapping_fun, reducing_fun)))
  end

  @doc """
  Maps `fun` over each of the elements in the Conc List, and returns a new Conc List with the results. 
  """
  @spec map(conc_list, (a -> b)) :: conc_list when a: any, b: any 
  def map(xs, fun) do
    map_reduce(xs, [], &[fun.(&1)], &append/2)
  end

  @doc """
  Reduces the Conc List to a single value, using the passed accumulator identity and reducing function that takes two elements.
  """
  @spec reduce(conc_list, c, ((c, a) -> c)) :: c when a: any, c: any
  def reduce(xs, id, g) do
    map_reduce(xs, id, &(&1), g)
  end

  @doc """
  Returns the length of the Conc list.
  """
  @spec length(conc_list) :: integer
  def length(xs) do
    map_reduce(xs, 0, fn _ -> 1 end, &(&1 + &2))
  end

  @doc """
  Returns a Conc list with all values for which the passed function is truthy, removed.
  """
  @spec filter(conc_list, (any -> as_boolean(any))) :: conc_list
  def filter(xs, fun) do
    map_reduce(xs, [], fn x ->
      if fun.(x), do: [x], else: []
    end,
    &append/2)
  end

  ## Utilities

  @doc """
  Rebalances the Conc List so all elements can be accessed with about similar efficiency.
  """
  @spec rebalance(conc_list) :: conc_list
  def rebalance(xs)

  def rebalance([]), do: []
  def rebalance([xs]), do: [xs]
  def rebalance(xs = [left | right]) do
    length_left = Conc.length(left)
    length_right = Conc.length(right)

    # Rebalance This Level

    xs2 =
      cond do
        length_left  > length_right -> rebalance(rotate(left, right))
        length_right > length_left  -> rebalance(rotate(right, left))
        true -> xs
      end

    # Rebalance Children
    case xs2 do
      [left2 | right2] ->
        # This is where we can add paralellism in the future.
        [rebalance(left2) | rebalance(right2)]
      _ ->
        xs2
    end
  end



  # What does this do exactly?
  def rotate(left, right)

  def rotate([],                right ), do: right
  def rotate(left,              []    ), do: left
  def rotate([left],            right ), do: [left|right]
  def rotate([left_a|left_b],  [right]), do: [left_a|[left_b|right]]
  def rotate([left_a|left_b],   right ), do: [left_a|[left_b|right]]



  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
    ]

    opts = [strategy: :one_for_one, name: Conc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
