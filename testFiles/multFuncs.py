def factorial(N):
  answer = N
  N = N - 1
  while N != 0:
    answer = answer * N
    N = N - 1
  end
  answer
end

def C(n,r):
  origN = n
  facN = n
  n = n - 1
  while n != 0:
    facN = facN * n
    n = n - 1
  end
  origR = r
  facR = r
  r = r - 1
  while r != 0:
    facR = facR * r
    r = r - 1
  end
  nr = origN - origR
  facNR = nr
  nr = nr - 1
  while nr != 0:
    facNR = facNR * nr
    nr = nr - 1
  end
  answer = (facN) / (facR * facNR)
  answer
end

C(10,5)
factorial(10)