defmodule ConcTest do
  use ExUnit.Case, async: true

  import Conc, except: [length: 1]

  @balanced_4 [[s(1) | s(2)] | [s(3) | s(4)]]
  @unbalanced_4 [[[s(1) | s(2)] | s(3)] | s(4)]

  @three [s(1) | [s(2) | s(3)]]

  test "singleton invariant" do
    assert s(item(s(1))) == s(1)
  end

  test "conc" do
    assert conc(s(1), s(2)) == [s(1) | (s(2))]
  end

  test "first" do
    assert first(@balanced_4) == 1
    assert first(@unbalanced_4) == 1
  end

  test "rest" do
    assert rest(@balanced_4) == [s(2) | [s(3) | s(4)]]
    assert rest(@unbalanced_4) == [[s(2) | s(3)] | s(4)]
  end

  test "add_left" do
    assert add_left(@balanced_4, 1) == [s(1) | @balanced_4]
    assert add_left(@unbalanced_4, 1) == [s(1) | @unbalanced_4]
  end

  test "add_right" do
    assert add_right(@balanced_4, 1) == [@balanced_4 | s(1)]
    assert add_right(@unbalanced_4, 1) == [@unbalanced_4 | s(1)]
  end

  test "map" do
    assert map(@balanced_4, &(&1 * 2)) == [[s(2) | s(4)] | [s(6) | s(8)]]
    assert map(@unbalanced_4, &(&1 * 2)) == [[[s(2) | s(4)] | s(6)] | s(8)]
    assert map(@three, &(&1 * 2)) == [s(2) | [s(4) | s(6)]]
  end

  test "length" do
    assert Conc.length(@balanced_4) == 4
    assert Conc.length(@unbalanced_4) == 4
  end

  test "filter" do
    assert filter([[s(1) | s(2)] | [s(3) | s(4)]], &(rem(&1, 2) == 0)) == [s(2) | s(4)]
  end

  test "reverse" do
    assert reverse([[s(1) | s(2)] | [s(3) | s(4)]]) == [[s(4) | s(3)] | [s(2) | s(1)]]
  end

  test "split invariant" do
    list = [[s(1) | s(2)] | [s(3) | s(4)]]

    assert conc(left(list), right(list)) == list
    assert split(list, &conc/2) == list
  end

  test "from_list/1 works" do
    assert from_list([]) == []
    assert from_list([1]) == s(1)
    assert from_list([1,2,3,4]) == [s(1) | [s(2) | [s(3) | s(4)]]]
  end

  test "to_list/1 works" do
    assert to_list(@balanced_4) == [1,2,3,4]
    assert to_list(from_list([1,2,3,4])) == [1,2,3,4]
  end
end
