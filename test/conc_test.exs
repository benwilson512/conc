defmodule ConcTest do
  use ExUnit.Case, async: true

  import Conc, except: [from_list: 1]

  test "singleton invariant" do
    assert [item([1])] == [1]
  end

  test "first" do
    assert first([[[1]|[2]]|[[3]|[4]]]) == 1
  end

  test "rest" do
    assert rest([[[1]|[2]]|[[3]|[4]]]) == [[2]|[[3]|[4]]]
  end

  test "add_left" do
    assert add_left([[2]|[[3]|[4]]], 1) == [[1]|[[2]|[[3]|[4]]]]
  end

  test "add_right" do
    assert add_right([[2]|[[3]|[4]]], 1) == [[[2]|[[3]|[4]]] | [1]]
  end

  test "map" do
    assert map([[[1]|[2]]|[[3]|[4]]], &(&1 * 2)) == [[[2]|[4]]|[[6]|[8]]]
  end

  test "length" do
    assert Conc.length([[[1]|[2]]|[[3]|[4]]]) == 4
  end

  test "filter" do
    assert filter([[[1]|[2]]|[[3]|[4]]], &(rem(&1, 2) == 0)) == [[2] | [4]]
  end

  test "reverse" do
    assert reverse([[[1]|[2]]|[[3]|[4]]]) == [[[4]|[3]]|[[2]|[1]]]
  end

  test "split invariant" do
    list = [[[1]|[2]]|[[3]|[4]]]

    assert conc(left(list), right(list)) == list
    assert split(list, &conc/2) == list
  end

  # test "from_list/1 works" do
  #   assert Conc.from_list([1,2,3,4]) == [[1|2]|[3|4]]
  # end
end
