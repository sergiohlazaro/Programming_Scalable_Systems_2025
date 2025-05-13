defmodule Sheet4 do
  defmodule Bank do
    use GenServer

    @db :bank_dets
    @filename 'bank.dets'  # ← nombre corregido

    def init(_init_arg) do
      :dets.open_file(@db, [file: @filename])
      state = :dets.foldl(fn {k, v}, acc -> Map.put(acc, k, v) end, %{}, @db)
      {:ok, state}
    end

    def terminate(_reason, _state) do
      :dets.close(@db)
      :ok
    end

    def handle_call({:new_account, account}, _from, state) do
      if Map.has_key?(state, account) do
        {:reply, false, state}
      else
        :dets.insert(@db, {account, 0})
        {:reply, true, Map.put(state, account, 0)}
      end
    end

    def handle_call({:balance, account}, _from, state) do
      balance = Map.get(state, account, 0)
      {:reply, balance, state}
    end

    def handle_call({:deposit, account, amount}, _from, state) do
      current = Map.get(state, account, 0)
      new_balance = current + amount
      :dets.insert(@db, {account, new_balance})
      {:reply, new_balance, Map.put(state, account, new_balance)}
    end

    def handle_call({:withdraw, account, amount}, _from, state) do
      current = Map.get(state, account, 0)
      withdrawn = min(current, amount)
      new_balance = current - withdrawn
      :dets.insert(@db, {account, new_balance})
      {:reply, withdrawn, Map.put(state, account, new_balance)}
    end

    def handle_call({:transfer, from, to, amount}, _from, state) do
      from_balance = Map.get(state, from, 0)
      to_balance = Map.get(state, to, 0)

      transferred = min(from_balance, amount)

      new_state =
        state
        |> Map.put(from, from_balance - transferred)
        |> Map.put(to, to_balance + transferred)

      :dets.insert(@db, {from, from_balance - transferred})
      :dets.insert(@db, {to, to_balance + transferred})

      {:reply, transferred, new_state}
    end

    # --- Client API ---

    def create_bank() do
      {:ok, pid} = GenServer.start_link(__MODULE__, %{}, [])
      pid
    end

    def new_account(bank \\ :bank, account) do
      GenServer.call(bank, {:new_account, account})
    end

    def balance(bank \\ :bank, account) do
      GenServer.call(bank, {:balance, account})
    end

    def deposit(bank \\ :bank, account, amount) do
      GenServer.call(bank, {:deposit, account, amount})
    end

    def withdraw(bank \\ :bank, account, amount) do
      GenServer.call(bank, {:withdraw, account, amount})
    end

    def transfer(bank \\ :bank, from, to, amount) do
      GenServer.call(bank, {:transfer, from, to, amount})
    end
  end

  defmodule BankSupervisor do
    use Supervisor

    def start_link(_) do
      Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init(_) do
      children = [
        %{
          id: Bank,
          start: {Sheet4.Bank, :create_bank, []},
          restart: :permanent,
          type: :worker
        }
      ]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end
end