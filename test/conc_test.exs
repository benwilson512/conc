defmodule ConcTest do
  use ExUnit.Case, async: true

  import Conc, except: [from_list: 1]

  @balanced_4 [[list(1) | list(2)] | [list(3) | list(4)]]
  @unbalanced_4 [[[list(1) | list(2)] | list(3)] | list(4)]

  @three [list(1) | [list(2) | list(3)]]

  test "singleton invariant" do
    assert list(item(list(1))) == list(1)
  end

  test "first" do
    assert first(@balanced_4) == 1
    assert first(@unbalanced_4) == 1
  end

  test "rest" do
    assert rest(@balanced_4) == [list(2) | [list(3) | list(4)]]
    assert rest(@unbalanced_4) == [[list(2) | list(3)] | list(4)]
  end

  test "add_left" do
    assert add_left(@balanced_4, 1) == [list(1) | @balanced_4]
    assert add_left(@unbalanced_4, 1) == [list(1) | @unbalanced_4]
  end

  test "add_right" do
    assert add_right(@balanced_4, 1) == [@balanced_4 | list(1)]
    assert add_right(@unbalanced_4, 1) == [@unbalanced_4 | list(1)]
  end

  test "map" do
    assert map(@balanced_4, &(&1 * 2)) == [[list(2) | list(4)] | [list(6) | list(8)]]
    assert map(@unbalanced_4, &(&1 * 2)) == [[[list(2) | list(4)] | list(6)] | list(8)]
    assert map(@three, &(&1 * 2)) == [list(2) | [list(4) | list(6)]]
  end

  test "length" do
    assert Conc.length(@balanced_4) == 4
    assert Conc.length(@unbalanced_4) == 4
  end

  test "filter" do
    assert filter([[list(1)|list(2)]|[list(3)|list(4)]], &(rem(&1, 2) == 0)) == [list(2) | list(4)]
  end

  test "reverse" do
    assert reverse([[list(1)|list(2)]|[list(3)|list(4)]]) == [[list(4)|list(3)]|[list(2)|list(1)]]
  end

  test "split invariant" do
    list = [[list(1)|list(2)]|[list(3)|list(4)]]

    assert conc(left(list), right(list)) == list
    assert split(list, &conc/2) == list
  end

  # test "from_list/1 works" do
  #   assert Conc.from_list([1,2,3,4]) == [[1|2]|[3|4]]
  # end
end
