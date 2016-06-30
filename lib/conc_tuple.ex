defmodule ConcTuple do

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
  def null?({}), do: true
  def null?(_), do: false

  @doc """
  Returns true if we have a Conc List with exactly one element, `false` for anything else.
  """
  @spec singleton?(conc_list) :: boolean
  def singleton?({_}), do: true
  def singleton?(_), do: false

  @doc """
  Returns the contents of a singleton Conc List.
  """
  @spec item(conc_list) :: boolean
  def item({x}), do: x

  @doc """
  Wraps `x` in a Conc List
  """
  def list(x), do: {x}

  @doc """
  Returns the left partition of the Conc List.
  """
  @spec left(conc_list) :: conc_list
  def left({left, _}), do: left

  @doc """
  Returns the right partition of the Conc List.
  """
  @spec right(conc_list) :: conc_list
  def right({_ , right}), do: right

  @doc """
  Splits the Conc List, and calls the function with `left` as first parameter, and `right` as second.

  This function is mostly useful to build higher-level abstractions on top of.
  """
  @spec split(conc_list, ((conc_list, conc_list) -> any)) :: any
  def split({}), do: raise ArgumentError, "You can't split a null Conc List"
  def split({_}), do: raise ArgumentError, "You can't split a singleton Conc List"
  def split({left, right}, fun) do
    fun.(left, right)
  end

  @doc """
  Combines two Conc Lists into one.
  """
  @spec conc(conc_list, conc_list) :: conc_list
  def conc(left, right), do: {left, right}

  ## Basics
  #####################

  @doc """
  Returns the first element of the Conc List.  
  
  TODO: Maybe throw error if empty Conc List?
  """
  @spec first(conc_list) :: any
  def first({}), do: {}
  def first({x}), do: x
  def first(xs) do
    split(xs, fn left, _ -> first(left) end)
  end

  @doc """
  Returns anything but the first element of the Conc List.  
  
  TODO: Maybe throw error if empty Conc List?
  """
  @spec rest(conc_list) :: any
  def rest({}), do: {}
  def rest({_}), do: {}
  def rest(xs) do
    split(xs, fn left, right ->
      append(rest(left), right)
    end)
  end

  @doc """
  Appends two Conc Lists together.
  """
  @spec append(conc_list, conc_list) :: conc_list
  def append({}, ys), do: ys
  def append(xs, {}), do: xs
  def append(xs, ys), do: {xs, ys} |> rebalance

  @doc """
  Adds a value to the leftmost side (the front) of the Conc List
  """
  @spec add_left(conc_list, any) :: conc_list
  def add_left(xs, x), do: append(list(x), xs)

  @doc """
  Adds a value to the leftmost side (the end) of the Conc List
  """
  @spec add_right(conc_list, any) :: conc_list
  def add_right(xs, x), do: append(xs, list(x))

  @doc """
  Converts a List into a Conc List
  """
  @spec from_list(list) :: conc_list
  def from_list([]), do: {}
  def from_list([x]), do: list(x)
  def from_list([head|tail]) do
    {{head}, from_list(tail)}
    # |> rebalance
  end

  def to_list(xs) do
    reduce(xs, [], 
      fn 
        x, acc -> [x] ++ [acc]
    end) |> IO.inspect |> :lists.flatten
  end

  # I believe that this might be a better solution than using `:lists.flatten` as you might flatten too much in that case.
  # But it isn't completely working in the last version.
  # def fix_improper_list_end([]), do: []
  # def fix_improper_list_end([hd|tl]) when not(is_list(tl)), do: [hd|[tl]]
  # def fix_improper_list_end([hd|tl]), do: [hd|fix_improper_list_end(tl)]

  ## Fun Stuff
  #####################

  @doc """
  Maps and Reduces the Conc List in one go.

  Takes a Conc List, a starting accumulator value, a function to map with, and a function that is used to reduce the results of this map.
  """
  @spec map_reduce(conc_list, c, (a -> b), ((b, c) -> c)) :: b when a: any, b: any, c: any
  def map_reduce(xs, id, mapping_fun, reducing_fun)

  def map_reduce({}, id, _, _), do: id
  def map_reduce({x}, _, mapping_fun, _), do: mapping_fun.(x)
  def map_reduce(xs, id, mapping_fun, reducing_fun) do
    IO.puts "map_reduce called with #{inspect xs}"
    split(xs, &reducing_fun.(
      map_reduce(&1, id, mapping_fun, reducing_fun), 
      map_reduce(&2, id, mapping_fun, reducing_fun)
    ))
  end

  @doc """
  Maps `fun` over each of the elements in the Conc List, and returns a new Conc List with the results. 
  """
  @spec map(conc_list, (a -> b)) :: conc_list when a: any, b: any 
  def map(xs, fun) do
    map_reduce(xs, {}, &list(fun.(&1)), &append/2)
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
    map_reduce(xs, {}, fn x ->
      if fun.(x), do: list(x), else: {}
    end,
    &append/2)
  end

  def reverse(xs) do
    map_reduce(xs, {}, &list/1, fn ys, zs -> append(zs, ys) end)
  end

  ## Utilities

  @doc """
  Rebalances the Conc List so all elements can be accessed with about similar efficiency.
  """
  @spec rebalance(conc_list) :: conc_list
  def rebalance(xs)#, do: xs


  def rebalance({}), do: {}
  def rebalance({x}), do: list(x)
  def rebalance(xs = {left, right}) do
    length_left = ConcTuple.length(left)
    length_right = ConcTuple.length(right)

    # Rebalance This Level

    xs2 =
      cond do
        length_left  >= length_right + 2  -> rebalance(rot_right(left, right)) |> IO.inspect
        length_right >= length_left  + 2  -> rebalance(rot_left(left,  right)) |> IO.inspect
        true -> xs
      end
    IO.puts "xs2 is now: #{inspect xs2}"

    # Rebalance Children
    case xs2 do
      {left2, right2} ->
        # This is where we can add paralellism in the future.
        {rebalance(left2), rebalance(right2)}
      _ ->
        xs2
    end
  end



  # Combines left and right, possibly moving the rightmost element from `left` to the start of `right`.
  # This is basically a tree rotation, https://en.wikipedia.org/wiki/Tree_rotation
  # i.e.: ({a,b}, c) -> ({a, {b, c}})
  # def rotate(left, right)

  # def rotate({},                 right ), do: right
  # def rotate(left,               {}    ), do: left
  # def rotate({left},             right ), do: {{left}, right}
  # def rotate({left_a, left_b},  {right}), do: {left_a, {left_b, {right}}} # These two last cases are actually the same...
  # def rotate({left_a, left_b},   right ), do: {left_a, {left_b, right}}


  def rot_right({}, right), do: right
  def rot_right(left, {}), do: left
  def rot_right({left}, right), do: {{left}, right}
  def rot_right({left_a, left_b}, right), do: {left_a, {left_b, right}}

  def rot_left({}, right), do: right
  def rot_left(left, {}), do: left
  def rot_left(left, {right}), do: {left, {right}}
  def rot_left(left, {right_a, right_b}), do: {{left, right_a}, right_b}

end
