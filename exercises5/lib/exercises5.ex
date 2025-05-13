defmodule Final do
  # --- Exercise 1: Matrix Transpose ---
  def transpose(rows) do
    rows |> Enum.zip() |> Enum.map(&Tuple.to_list/1)
  end

  # --- Exercise 2: Matrix Product ---
  def matrixprod(a, b) do
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
  def tree_insert(:tip, value), do: {:node, :tip, value, :tip}

  def tree_insert({:node, left, current, right}, value) when value <= current do
    {:node, tree_insert(left, value), current, right}
  end

  def tree_insert({:node, left, current, right}, value) do
    {:node, left, current, tree_insert(right, value)}
  end

  # --- Exercise 4: In-order Traversal ---
  def inorder(:tip), do: []

  def inorder({:node, left, value, right}) do
    inorder(left) ++ [value] ++ inorder(right)
  end

  # --- Exercise 5: Map Tree ---
  def map_tree(:tip, _fun), do: :tip

  def map_tree({:node, left, value, right}, fun) do
    {:node, map_tree(left, fun), fun.(value), map_tree(right, fun)}
  end

  # --- Exercise 6: GenBank with GenServer ---
  defmodule GenBank do
    use GenServer

    # API
    def create_bank(name \\ nil) do
      case name do
        nil -> GenServer.start_link(__MODULE__, %{})
        _ -> GenServer.start_link(__MODULE__, %{name: name, accounts: %{}}, name: name)
      end
    end

    def new_account(bank, account), do: GenServer.call(bank, {:new_account, account})
    def deposit(bank, account, amount), do: GenServer.call(bank, {:deposit, account, amount})
    def withdraw(bank, account, amount), do: GenServer.call(bank, {:withdraw, account, amount})
    def transfer(bank, from, to, amount), do: GenServer.call(bank, {:transfer, from, to, amount})
    def balance(bank, account), do: GenServer.call(bank, {:balance, account})

    # GenServer Callbacks
    @impl true
    def init(state) when is_map(state) do
      {:ok, Map.put_new(state, :accounts, %{})}
    end

    @impl true
    def handle_call({:new_account, account}, _from, %{accounts: accs} = state) do
      if Map.has_key?(accs, account) do
        {:reply, false, state}
      else
        new_accs = Map.put(accs, account, 0)
        {:reply, true, %{state | accounts: new_accs}}
      end
    end

    @impl true
    def handle_call({:deposit, account, amount}, _from, %{accounts: accs} = state) do
      current = Map.get(accs, account, 0)
      new_balance = current + amount
      {:reply, new_balance, %{state | accounts: Map.put(accs, account, new_balance)}}
    end

    @impl true
    def handle_call({:withdraw, account, amount}, _from, %{accounts: accs} = state) do
      current = Map.get(accs, account, 0)
      withdrawn = min(current, amount)
      new_balance = current - withdrawn
      {:reply, withdrawn, %{state | accounts: Map.put(accs, account, new_balance)}}
    end

    @impl true
    def handle_call({:transfer, from, to, amount}, _from, %{accounts: accs} = state) do
      bfrom = Map.get(accs, from, 0)
      bto = Map.get(accs, to, 0)
      moved = min(bfrom, amount)

      new_accs =
        accs
        |> Map.put(from, bfrom - moved)
        |> Map.put(to, bto + moved)

      {:reply, moved, %{state | accounts: new_accs}}
    end

    @impl true
    def handle_call({:balance, account}, _from, %{accounts: accs} = state) do
      {:reply, Map.get(accs, account, 0), state}
    end
  end

  # --- Exercise 7: SuperBank Supervisor ---
  defmodule SuperBank do
    use Supervisor

    def create_bank(name) do
      Supervisor.start_link(__MODULE__, name, name: via_super_name(name))
    end

    @impl true
    def init(name) do
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
