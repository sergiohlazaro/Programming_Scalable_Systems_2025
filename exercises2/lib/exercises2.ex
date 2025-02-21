defmodule Sheet2 do
  # Ejercicio 1: Longitud de una lista
  def len([]), do: 0
  def len([_ | tail]), do: 1 + len(tail)

  # Ejercicio 2: Concatenar listas
  def app([], list2), do: list2
  def app([head | tail], list2), do: [head | app(tail, list2)]

  # Ejercicio 3: Fibonacci (recursivo)
  def fib(1), do: 1
  def fib(2), do: 1
  def fib(n), do: fib(n - 1) + fib(n - 2)

  # Ejercicio 4: Máximo Común Divisor (Euclides)
  def gcd(n, 0), do: n
  def gcd(n, m), do: gcd(m, rem(n, m))

  # Ejercicio 5: Fibonacci como lista
  def fibs(0), do: []
  def fibs(1), do: [1]
  def fibs(2), do: [1, 1]
  def fibs(n) do
    fibs(n - 1) ++ [Enum.at(fibs(n - 1), -1) + Enum.at(fibs(n - 2), -1)]
  end

  # Ejercicio 6: Reverso de una lista
  def reverse([]), do: []
  def reverse([head | tail]), do: reverse(tail) ++ [head]

  # Ejercicio 7: Reverso concatenado con otra lista
  def revonto([], ys), do: ys
  def revonto([head | tail], ys), do: revonto(tail, [head | ys])

  # Ejercicio 8: Triángulo de Pascal
  def pascal(0), do: [1]
  
  def pascal(n) do
    prev_row = pascal(n - 1)
    middle_values = Enum.chunk_every(prev_row, 2, 1, :discard) |> Enum.map(&Enum.sum/1)
    [1] ++ middle_values ++ [1]
  end

  # Ejercicio 9: MergeSort
  def mergesort([]), do: []
  def mergesort([x]), do: [x]
  def mergesort(list) do
    {left, right} = Enum.split(list, div(length(list), 2))
    merge(mergesort(left), mergesort(right))
  end

  defp merge([], right), do: right
  defp merge(left, []), do: left
  defp merge([h1 | t1] = left, [h2 | t2] = right) do
    if h1 <= h2 do
      [h1 | merge(t1, right)]
    else
      [h2 | merge(left, t2)]
    end
  end

  # Ejercicio 10: Permutaciones de una lista
  def permuts([]), do: []
  def permuts([x]), do: [[x]]
  def permuts(list), do: for x <- list, rest <- permuts(List.delete(list, x)), do: [x | rest]

  # Ejercicio 11: Operaciones con vectores
  def vadd([], []), do: []
  def vadd([h1 | t1], [h2 | t2]), do: [h1 + h2 | vadd(t1, t2)]

  def scale([], _), do: []
  def scale([h | t], s), do: [h * s | scale(t, s)]

  def dotprod([], []), do: 0
  def dotprod([h1 | t1], [h2 | t2]), do: h1 * h2 + dotprod(t1, t2)

  # Ejercicio 16: Criba de Eratóstenes (Números primos hasta n)
  def primes_upto(n) when n < 2, do: []
  def primes_upto(n) do
    2..n
    |> Enum.filter(&is_prime/1)
  end

  defp is_prime(2), do: true
  defp is_prime(n) when n > 2 do
    max_divisor = max(2, :math.sqrt(n) |> floor())  # Evita rangos inválidos
    Enum.all?(2..max_divisor, fn x -> rem(n, x) != 0 end)
  end

  # Ejercicio 17: Factorización en números primos
  def factorize(n), do: factorize(n, 2, [])

  defp factorize(1, _, factors), do: factors
  defp factorize(n, d, factors) when rem(n, d) == 0, do: factorize(div(n, d), d, [d | factors])
  defp factorize(n, d, factors), do: factorize(n, d + 1, factors)

  # Ejercicio 18: Árboles binarios de búsqueda - Inserción
  def tree_insert(:tip, value), do: {:node, :tip, value, :tip}
  def tree_insert({:node, left, v, right}, value) when value < v, do: {:node, tree_insert(left, value), v, right}
  def tree_insert({:node, left, v, right}, value), do: {:node, left, v, tree_insert(right, value)}

  # Ejercicio 19: Ordenación de árbol binario (inorder)
  def inorder(:tip), do: []
  def inorder({:node, left, v, right}), do: inorder(left) ++ [v] ++ inorder(right)
end
