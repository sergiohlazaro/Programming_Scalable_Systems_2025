defmodule Exercises4Test do
  use ExUnit.Case

  test "bank_0" do
    bank = Sheet4.Bank.create_bank()
    assert Sheet4.Bank.new_account(bank,1) == true 
    assert Sheet4.Bank.new_account(bank,1) == false 
    assert Sheet4.Bank.balance(bank,1) == 0 
    assert Sheet4.Bank.deposit(bank,1,10) == 10 
    assert Sheet4.Bank.new_account(bank,2) == true 
    assert Sheet4.Bank.balance(bank,2) == 0 
    assert Sheet4.Bank.transfer(bank,1,2,5) == 5 
    assert Sheet4.Bank.balance(bank,1) == 5 
    assert Sheet4.Bank.balance(bank,2) == 5 
    assert Sheet4.Bank.withdraw(bank,2,3) == 3 
    assert Sheet4.Bank.balance(bank,2) == 2 
  end
end
