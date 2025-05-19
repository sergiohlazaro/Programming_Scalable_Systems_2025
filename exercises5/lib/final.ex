defmodule Final do
  # --- Exercise 1: Matrix Transpose ---
  def transpose(rows) do
    IO.puts("[transpose] called")
    rows
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  # --- Exercise 2: Matrix Product ---
  def matrixprod(a, b) do
    IO.puts("[matrixprod] called")
    bt = transpose(b)
    for row_a <- a do
      for col_b <- bt do
        Enum.zip(row_a, col_b)
        |> Enum.map(fn {x, y} -> x * y end)
        |> Enum.sum()
      end
    end
  end

  # --- Exercise 3: Binary Tree Insertion ---
  def tree_insert(:tip, value) do
    IO.puts("[tree_insert] inserting #{value} into empty tree")
    {:node, :tip, value, :tip}
  end

  def tree_insert({:node, left, val, right}, value) when value < val do
    IO.puts("[tree_insert] inserting #{value} to the LEFT of #{val}")
    {:node, tree_insert(left, value), val, right}
  end

  def tree_insert({:node, left, val, right}, value) do
    IO.puts("[tree_insert] inserting #{value} to the RIGHT of #{val}")
    {:node, left, val, tree_insert(right, value)}
  end

  # --- Exercise 4: In-order Traversal ---
  def inorder(:tip), do: []
  def inorder({:node, left, value, right}) do
    IO.puts("[inorder] visiting node #{value}")
    inorder(left) ++ [value] ++ inorder(right)
  end

  # --- Exercise 5: Map Tree ---
  def map_tree(:tip, _fun), do: :tip
  def map_tree({:node, left, value, right}, fun) do
    IO.puts("[map_tree] applying function to #{value}")
    {:node, map_tree(left, fun), fun.(value), map_tree(right, fun)}
  end

  # --- Exercise 6: GenBank with GenServer ---
  defmodule GenBank do
    use GenServer

    # --- API ---
    def create_bank(name \\ nil) do
      IO.puts("[GenBank.create_bank] name=#{inspect name}")
      if name == nil do
        GenServer.start_link(__MODULE__, %{name: nil, accounts: %{}})
      else
        GenServer.start_link(__MODULE__, %{name: name, accounts: %{}}, name: name)
      end
    end

    def new_account(bank, account) do
      IO.puts("[GenBank.new_account] bank=#{inspect bank}, account=#{account}")
      GenServer.call(bank, {:new_account, account})
    end

    def withdraw(bank, account, qty) do
      IO.puts("[GenBank.withdraw] account=#{account}, qty=#{qty}")
      GenServer.call(bank, {:withdraw, account, qty})
    end

    def deposit(bank, account, qty) do
      IO.puts("[GenBank.deposit] account=#{account}, qty=#{qty}")
      GenServer.call(bank, {:deposit, account, qty})
    end

    def transfer(bank, from, to, qty) do
      IO.puts("[GenBank.transfer] from=#{from}, to=#{to}, qty=#{qty}")
      GenServer.call(bank, {:transfer, from, to, qty})
    end

    def balance(bank, account) do
      IO.puts("[GenBank.balance] account=#{account}")
      GenServer.call(bank, {:balance, account})
    end

    # --- Callbacks ---
    @impl true
    def init(%{name: name} = state) when is_atom(name) do
      IO.puts("[GenBank.init] loading state from DETS for #{name}")
      filename = String.to_charlist("#{name}.dets")
      :dets.open_file(name, [file: filename])
      accounts = :dets.foldl(fn {k, v}, acc -> Map.put(acc, k, v) end, %{}, name)
      {:ok, %{state | accounts: accounts}}
    end

    @impl true
    def init(%{name: nil} = state) do
      IO.puts("[GenBank.init] initializing unnamed bank")
      {:ok, state}
    end

    defp persist(nil, _k, _v), do: :ok
    defp persist(name, k, v) do
      IO.puts("[persist] saving #{k} => #{v} to #{name}.dets")
      :dets.insert(name, {k, v})
    end

    @impl true
    def handle_call({:new_account, account}, _from, %{name: name, accounts: accs} = state) do
      IO.puts("[handle_call:new_account] account=#{account}")
      if Map.has_key?(accs, account) do
        {:reply, false, state}
      else
        new_accs = Map.put(accs, account, 0)
        persist(name, account, 0)
        {:reply, true, %{state | accounts: new_accs}}
      end
    end

    def handle_call({:withdraw, account, qty}, _from, %{name: name, accounts: accs} = state) do
      IO.puts("[handle_call:withdraw] account=#{account}, qty=#{qty}")
      current = Map.get(accs, account, 0)
      withdrawn = min(current, qty)
      new_balance = current - withdrawn
      persist(name, account, new_balance)
      new_accs = Map.put(accs, account, new_balance)
      {:reply, withdrawn, %{state | accounts: new_accs}}
    end

    def handle_call({:deposit, account, qty}, _from, %{name: name, accounts: accs} = state) do
      IO.puts("[handle_call:deposit] account=#{account}, qty=#{qty}")
      current = Map.get(accs, account, 0)
      new_balance = current + qty
      persist(name, account, new_balance)
      new_accs = Map.put(accs, account, new_balance)
      {:reply, new_balance, %{state | accounts: new_accs}}
    end

    def handle_call({:transfer, from, to, qty}, _from, %{name: name, accounts: accs} = state) do
      IO.puts("[handle_call:transfer] from=#{from}, to=#{to}, qty=#{qty}")
      bfrom = Map.get(accs, from, 0)
      bto = Map.get(accs, to, 0)
      moved = min(bfrom, qty)

      new_accs =
        accs
        |> Map.put(from, bfrom - moved)
        |> Map.put(to, bto + moved)

      persist(name, from, bfrom - moved)
      persist(name, to, bto + moved)

      {:reply, moved, %{state | accounts: new_accs}}
    end

    def handle_call({:balance, account}, _from, %{accounts: accs} = state) do
      IO.puts("[handle_call:balance] account=#{account}")
      {:reply, Map.get(accs, account, 0), state}
    end
  end

  # --- Exercise 7: SuperBank Supervisor ---
  defmodule SuperBank do
    use Supervisor

    def create_bank(name) do
      IO.puts("[SuperBank.create_bank] name=#{inspect name}")
      Supervisor.start_link(__MODULE__, name)
    end

    @impl true
    def init(name) do
      IO.puts("[SuperBank.init] initializing with GenBank name=#{inspect name}")
      children = [
        %{
          id: GenBank,
          start: {Final.GenBank, :create_bank, [name]},
          restart: :permanent,
          type: :worker
        }
      ]

      Supervisor.init(children, strategy: :one_for_one)
    end

    defp via_super_name(name), do: String.to_atom("Super_#{name}")
  end
end
