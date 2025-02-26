defmodule Sheet2 do
  # Ejercicio 1: longitud de una lista
  def len([]), do: 0
  def len([_ | tail]), do: 1 + len(tail)
  
  # Ejercicio 2: concatenacion de listas
  def app([], l2), do: l2
  def app([head | tail], l2), do: [head | app(tail, l2)]

  # Ejercicio 3: secuencia de Fibonacci
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n) when n > 1, do: fib(n - 1) + fib(n - 2)

  # Ejercicio 4: algoritmo de Euclides
  def gcd(a, 0), do: a
  def gcd(a, b), do: gcd(b, rem(a, b))

  # Ejercicio 5: Fibonacci optimizado con acumuladores
  def fibs(n), do: fibs_helper(n, [1, 0]) |> Enum.reverse()

  defp fibs_helper(1, acc), do: acc
  defp fibs_helper(n, [a, b | _] = acc), do: fibs_helper(n - 1, [a + b | acc])

  def fib_optimized(n), do: List.last(fibs(n))

  # Ejercicio 6: inversion de una lista
  # def reverse([]), do: []
  # def reverse([head | tail]), do: reverse(tail) ++ [head]

  # Ejercicio 7: inversion optimizado de una lista
  def revonto([], ys), do: ys
  def revonto([head | tail], ys), do: revonto(tail, [head | ys])

  def reverse(xs), do: revonto(xs, [])

  # Ejercicio 8: numeros combinatorios y triangulo de Pascal
  def pascal(0), do: [1]
  def pascal(n) do
    prev = pascal(n - 1)
    [1 | zip_with(prev)] ++ [1]
  end

  defp zip_with([a, b | rest]), do: [a + b | zip_with([b | rest])]
  defp zip_with(_), do: []

  def comb(n, m), do: Enum.at(pascal(n), m)

  # Ejercicio 9: algoritmo MergeSort
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

  # Ejercicio 10: generacion de permutaciones 
  def permuts([]), do: []  # Cambio aquí: antes devolvía [[]]
  def permuts(list) do
    for elem <- list, rest <- permuts(List.delete(list, elem)), do: [elem | rest]
  end

  # Ejercicio 11: operaciones con vectores
  # Suma de vectores
  def vadd([], []), do: []
  def vadd([a | at], [b | bt]), do: [a + b | vadd(at, bt)]

  # Multiplicación por escalar
  def scale(_, []), do: []
  def scale(scalar, [h | t]), do: [scalar * h | scale(scalar, t)]

  # Producto escalar
  def dotprod([], []), do: 0
  def dotprod([a | at], [b | bt]), do: a * b + dotprod(at, bt)

  # Ejercicio 12: dimensiones de una matriz 
  def dim([]), do: {0, 0} # Matriz vacía
  def dim(matrix), do: {length(matrix), length(hd(matrix))}

  # Ejercicio 13: suma de matrices 
  def matrixsum([], []), do: []
  def matrixsum([row_a | rest_a], [row_b | rest_b]) do
    [vadd(row_a, row_b) | matrixsum(rest_a, rest_b)]
  end

  # defp vadd([], []), do: []
  # defp vadd([a | at], [b | bt]), do: [a + b | vadd(at, bt)]

  # Ejercicio 14: transposicion de una matriz 
  def transpose(matrix) do
    if Enum.uniq(Enum.map(matrix, &length/1)) |> length() == 1 do
      do_transpose(matrix)
    else
      {:error, "Las filas tienen diferente número de columnas"}
    end
  end

  defp do_transpose([]), do: []
  defp do_transpose([[] | _]), do: []
  defp do_transpose(matrix) do
    [Enum.map(matrix, &hd/1) | do_transpose(Enum.map(matrix, &tl/1))]
  end

  # Ejercicio 15: producto de matrices 
  def matrixprod(a, b) do
    if valid_matrices?(a, b) do
      b_t = transpose(b)  # Aquí usamos la versión pública de transpose/1
      for row <- a do
        for col <- b_t do
          dotprod(row, col)
        end
      end
    else
      {:error, "Dimensiones incompatibles para multiplicación"}
    end
  end

  # defp dotprod([], []), do: 0
  # defp dotprod([a | at], [b | bt]), do: a * b + dotprod(at, bt)

  defp valid_matrices?(a, b) do
    case {a, b} do
      {[], _} -> false
      {_, []} -> false
      {[_ | _], [_ | _]} -> length(hd(a)) == length(b)
    end
  end

  # Ejercicio 16: criba de Erastotenes para numeros primos
  def primes_upto(n) when n < 2, do: []

  def primes_upto(n) do
    2..n
    |> Enum.to_list()
    |> sieve()
  end

  defp sieve([]), do: []
  defp sieve([prime | rest]) do
    [prime | sieve(Enum.filter(rest, fn x -> rem(x, prime) != 0 end))]
  end

  # Ejercicio 17: factorizacion en numeros primos (usamos la version publica de primes_upto/1)
  def factorize(n) when n < 2, do: []

  def factorize(n) do
    primes = primes_upto(n)  # Usamos la función pública de Ejercicio 16
    do_factorize(n, primes)
  end

  defp do_factorize(1, _), do: []
  defp do_factorize(n, [p | rest]) when rem(n, p) == 0 do
    [p | do_factorize(div(n, p), [p | rest])]
  end
  defp do_factorize(n, [_ | rest]), do: do_factorize(n, rest)

  # Ejercicio 18: inserccion de arboles binarios de busqueda
  def tree_insert(:tip, value), do: {:node, :tip, value, :tip}

  def tree_insert({:node, left, val, right}, value) when value < val do
    {:node, tree_insert(left, value), val, right}
  end

  def tree_insert({:node, left, val, right}, value) do
    {:node, left, val, tree_insert(right, value)}
  end

  # Ejercicio 19: recorrido en oden de un arbol binario (Tree Sort)
  # Recorrido en orden del árbol
  def inorder(:tip), do: []
  def inorder({:node, left, value, right}) do
    inorder(left) ++ [value] ++ inorder(right)
  end

  # Ordenar una lista usando Tree Sort
  def treesort(list) do
    list
    |> Enum.reduce(:tip, &tree_insert/2)
    |> inorder()
  end

  # Inserción en el Árbol Binario de Búsqueda
  # def tree_insert(:tip, value), do: {:node, :tip, value, :tip}
  # def tree_insert({:node, left, val, right}, value) when value < val do
  #  {:node, tree_insert(left, value), val, right}
  # end
  # def tree_insert({:node, left, val, right}, value) do
  #  {:node, left, val, tree_insert(right, value)}
  # end

  # Ejercicio 20: revision de las lecturas

  # Ejercicio 21: practicas con Etudes en Elixir
  
  ## 21.4: invirtiendo una lista
  def reverse(list), do: reverse_helper(list, [])

  defp reverse_helper([], acc), do: acc
  defp reverse_helper([head | tail], acc), do: reverse_helper(tail, [head | acc])

  ## 21.5: contando elementos en una lista
  def count(list), do: count_helper(list, 0)

  defp count_helper([], acc), do: acc
  defp count_helper([_ | tail], acc), do: count_helper(tail, acc + 1)

  ## 21.6: numeros Fibonacci (sin recursion exponencial)
  def fibonacci(n), do: fib_helper(n, 0, 1)

  defp fib_helper(0, a, _), do: a
  defp fib_helper(n, a, b), do: fib_helper(n - 1, b, a + b)

  ## 21.7: encontrar el maximo de una lista
  def max([head | tail]), do: max_helper(tail, head)

  defp max_helper([], max), do: max
  defp max_helper([head | tail], max) when head > max, do: max_helper(tail, head)
  defp max_helper([_ | tail], max), do: max_helper(tail, max)

  ## 21.8: implementar el map/2 de Enum
  def my_map(list, func), do: map_helper(list, func, [])

  defp map_helper([], _func, acc), do: Enum.reverse(acc)
  defp map_helper([head | tail], func, acc), do: map_helper(tail, func, [func.(head) | acc])

  ## 21.13: implementar filter/2 de Enum
  def my_filter(list, func), do: filter_helper(list, func, [])

  defp filter_helper([], _func, acc), do: Enum.reverse(acc)
  defp filter_helper([head | tail], func, acc) do
    if func.(head) do
      filter_helper(tail, func, [head | acc])
    else
      filter_helper(tail, func, acc)
    end
  end

  # Ejercicio 22: implementacion de all/2
  def all?(list, func) do
    Enum.reduce_while(list, true, fn x, _acc ->
      if func.(x), do: {:cont, true}, else: {:halt, false}
    end)
  end

  # Ejercicio 23: implementacion de reverse_fold/1 usando List.foldr/2
  def reverse_fold(list) do
    List.foldr(list, [], fn x, acc -> acc ++ [x] end)
  end

  # Ejercicio 24: implementacion de revonto_fold/2 usando List.foldr/3
  def revonto_fold(xs, ys) do
    List.foldr(xs, ys, fn x, acc -> [x | acc] end)
  end

  # Ejercicio 25: implementacion de zip_with/3 usando Enum.map/2 y Enum.zip/2
  # def zip_with(func, list1, list2) do
  #  list1
  #  |> Enum.zip(list2)
  #  |> Enum.map(fn {x, y} -> func.(x, y) end)
  # end

  # Ejercicio 26: implementacion de pascal_zip/1 usando zip_with/3
  def pascal_zip(0), do: [1]
  def pascal_zip(n) do
    prev = pascal_zip(n - 1)
    [1 | zip_with(&+/2, prev, tl(prev))] ++ [1]
  end

  def zip_with(func, list1, list2) do
    list1
    |> Enum.zip(list2)
    |> Enum.map(fn {x, y} -> func.(x, y) end)
  end

  # Ejercicio 27: implementacion de operaciones con vectores usando funciones de orden superior
  # Suma de vectores usando Enum.zip y Enum.map
  def vadd_ho(v1, v2) do
    Enum.map(Enum.zip(v1, v2), fn {x, y} -> x + y end)
  end

  # Multiplicación por escalar usando Enum.map
  def scale_ho(scalar, vector) do
    Enum.map(vector, &(&1 * scalar))
  end

  # Producto escalar usando Enum.zip y Enum.reduce
  def dotprod_ho(v1, v2) do
    v1
    |> Enum.zip(v2)
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.reduce(0, &+/2)
  end

  # Ejercicio 28: 

end
