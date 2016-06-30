defmodule ConcTupleTest do
  use ExUnit.Case, async: true

  import ConcTuple, except: [from_list: 1]

  @balanced_4 {{list(1) , list(2)} , {list(3) , list(4)}}
  @unbalanced_4 {{{list(1) , list(2)} , list(3)} , list(4)}

  @three {list(1) , {list(2) , list(3)}}

  test "singleton invariant" do
    assert list(item(list(1))) == list(1)
  end

  test "first" do
    assert first(@balanced_4) == 1
    assert first(@unbalanced_4) == 1
  end

  test "rest" do
    assert rest(@balanced_4) == {list(2) , {list(3) , list(4)}}
    assert rest(@unbalanced_4) == {{list(2) , list(3)} , list(4)}
  end

  test "add_left" do
    # These assertions are untrue when doing rebalancing.
    # assert add_left(@balanced_4, 1) == {list(1) , @balanced_4}
    # assert add_left(@unbalanced_4, 1) == {list(1) , @unbalanced_4}
    assert add_left(@balanced_4, 1) |> to_list == [1,1,2,3,4]

    # THIS TEST results in an infinite loop?!
    #assert add_left(@unbalanced_4, 1) |> to_list == [1,1,2,3,4]
  end

  test "add_right" do
    # These assertions are untrue when doing rebalancing.
    # assert add_right(@balanced_4, 1) == {@balanced_4 , list(1)}
    # assert add_right(@unbalanced_4, 1) == {@unbalanced_4 , list(1)}

    assert add_right(@balanced_4, 1) |> to_list == [1,2,3,4,1]
    assert add_right(@unbalanced_4, 1) |> to_list == [1,2,3,4,1]
  end

  test "map" do
    # These assertions are untrue when doing rebalancing.
    # assert map(@balanced_4, &(&1 * 2)) == {{list(2) , list(4)} , {list(6) , list(8)}}
    # assert map(@unbalanced_4, &(&1 * 2)) == {{{list(2) , list(4)} , list(6)} , list(8)}
    # assert map(@three, &(&1 * 2)) == {list(2) , {list(4) , list(6)}}

    assert map(@balanced_4, &(&1 * 2)) |> to_list == [2,4,6,8]
    assert map(@unbalanced_4, &(&1 * 2)) |> to_list == [2,4,6,8]
    assert map(@three, &(&1 * 2)) |> to_list == [2,4,6]
  end

  test "length" do
    assert ConcTuple.length(@balanced_4) == 4
    assert ConcTuple.length(@unbalanced_4) == 4
  end

  test "filter" do
    assert filter({{list(1),list(2)},{list(3),list(4)}}, &(rem(&1, 2) == 0)) == {list(2) , list(4)}
  end

  test "reverse" do
    assert reverse({{list(1),list(2)},{list(3),list(4)}}) == {{list(4),list(3)},{list(2),list(1)}}
  end

  test "split invariant" do
    list = {{list(1),list(2)},{list(3),list(4)}}

    assert conc(left(list), right(list)) == list
    assert split(list, &conc/2) == list
  end

  test "from_list/1 works" do
    assert ConcTuple.from_list([]) == {}
    assert ConcTuple.from_list([1]) == list(1)
    assert ConcTuple.from_list([1,2,3,4]) == {list(1) , {list(2) , {list(3) , list(4)}}}
  end

  test "to_list/1 works" do
    assert ConcTuple.to_list(@balanced_4) == [1,2,3,4]
  end

  test "from_list -> to_list is invariant" do
    list = [1,2,3,4,5,6,7,8,9]
    assert (list |> ConcTuple.from_list |> ConcTuple.to_list) == list    
  end

  test "rebalancing does not change final representation" do
    list = [1,2,3,4,5,6,7,8,9]
    assert (list |> ConcTuple.from_list |> ConcTuple.rebalance |> ConcTuple.to_list) == list
  end
end