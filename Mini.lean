class MyClass (b : Bool) (n : Nat) where
  f : Nat → Bool

instance : MyClass true n where
  f x := n % x == 0

def foo (b : Bool) (n : Nat) : Bool :=
  if b then n % 2 == 0 else n % 3 == 0

def fooUsingClass (b : Bool) (n : Nat) [inst : MyClass b n] : Bool :=
  if b then inst.f n else n % 5 == 0

set_option linter.unusedVariables false in
def fooNotUsingClass (b : Bool) (n : Nat) [inst : MyClass b n] : Bool :=
  if b then n % 4 == 0 else n % 5 == 0

def isPrime (n : Nat) : Bool := Id.run do
  if n < 2 then false
  else
    for i in [2:n] do
      if i * i > n then break
      if n % i == 0 then return false
    return true

def isPrimeUsingClass (b : Bool) (n : Nat) [inst : MyClass b n] : Bool := Id.run do
  if n < 2 then false
  else
    for i in [2:n] do
      if i * i > n then break
      if inst.f i then return false
    return true

set_option linter.unusedVariables false in
def isPrimeNotUsingClass (b : Bool) (n : Nat) [inst : MyClass b n] : Bool := Id.run do
  if n < 2 then false
  else
    for i in [2:n] do
      if i * i > n then break
      if n % i == 0 then return false
    return true
