x = [1,2,3,4,5,6,7]

print "Here is your list"
x

y = raw_input("Would you like to add(A)/subtract(S)/divide(D)/multiply(M) all the elements together (Choose one or Q for quit): ")

while y != "Q":
  if y == "A":
    sum = 0
    counter = 0
    for z in x:
      sum = sum + x[counter]
      counter = counter + 1
    end
    sum
  else:
    if y == "S":
      difference = 0
      counter = 0
      for z in x:
        difference = difference - x[counter]
        counter = counter + 1
      end
      difference
    else:
      if y == "D":
        quotient = x[0]
        counter = 1
        while counter <= 6:
          quotient = quotient / x[counter]
          counter = counter + 1
        end
        quotient
      else:
        product = x[0]
        counter = 1
        while counter <= 6:
          product = product * x[counter]
          counter = counter + 1
        end
        product
      end
    end
  end
  y = raw_input("Would you like to add(A)/subtract(S)/divide(D)/multiply(M) all the elements together (Choose one or Q for quit): ")
end