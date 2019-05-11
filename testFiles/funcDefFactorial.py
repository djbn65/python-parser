def factorial(N):
  answer = N
  N = N - 1
  while N != 0:
    answer = answer * N
    N = N - 1
  end
  print answer
end

factorial(6)