defmodule Conc do

  @type empty :: []
  @type singleton :: [term]
  @type t :: empty | singleton | [term | term]



  ## Primatives
  #############
  def item([x]), do: x

  # this is necessary because `[x]` is in fact `[x | []]` and we don't want to
  # treat that as having a real left
  def left([left | right]) when right != [], do: left

  def right([_ | right]) when right != [], do: right

  def split([left | right], fun) do
    fun.(left, right)
  end

  def conc(left, right), do: [left | right]

  ## Other stuff
  #####################

  def first([]), do: []
  def first([x]), do: x
  def first(xs) do
    split(xs, fn ys, _ -> first(ys) end)
  end

  # def rest([]), do: []
  # def rest([_]), do: []
  # def rest(xs) do
  #   xs |> IO.inspect
  #   split(xs, fn ys, zs ->
  #     append(rest(ys), zs)
  #   end)
  # end

  def append([], ys), do: ys
  def append(xs, []), do: xs
  def append(xs, ys), do: [xs | ys]

  def from_list([]), do: []
  def from_list([x]), do: [x]
  def from_list(list) do
    list
  end

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
    ]

    opts = [strategy: :one_for_one, name: Conc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
