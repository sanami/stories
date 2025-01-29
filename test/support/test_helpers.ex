defmodule App.TestHelpers do
  @key :__test_helpers

  def seqn do
    n = Process.get(@key, 0)
    Process.put(@key, n + 1)
    n
  end

  def seqs(str, ext \\ "") do
    key = :"#{@key}_#{str}"
    n = Process.get(key, 1)
    Process.put(key, n + 1)

    "#{str}#{n}#{ext}"
  end

  def pp(exp), do: IO.inspect(exp)
end
