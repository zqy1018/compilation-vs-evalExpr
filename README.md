# Mini

A mini project for experimenting mixing the use of compiled code and code from `evalExpr`. 

The project contains 2 main files:
- `Mini.lean`: Defines a typeclass `MyClass` and several functions (`foo`, `fooUsingClass`, `fooNotUsingClass`, `isPrime`, `isPrimeUsingClass`, `isPrimeNotUsingClass`) with varying complexity and usage of the typeclass
- `Main.lean`: Implements two execution modes:
  - `main1`: Parses input string as a term syntax, and matches on the syntax
    - If the syntax is a pair, then extracts the two components, elaborates them, synthesizes the `MyClass` instance via `synthInstance`, uses `evalExpr` to evaluate them, and finally calls *compiled* functions with these runtime-evaluated values
    - Otherwise, uses `evalExpr` to evaluate the whole term
  - `main2`: Pure compiled execution without any `evalExpr`

The script `run.sh` tests across multiple dimensions (the outputs are in the `output` directory):
- Argument passing strategy:
  - `main1` + `byarg`: The syntax is a pair `(true, n)` where `n` is a number
  - `main1` + `bycall`: The syntax is a complete function call (e.g., `isPrimeUsingClass true 6306436948373`)
  - `main2`: A number is passed as a CLI argument
- Which function to call: `foo`, `fooUsingClass`, `fooNotUsingClass`, `isPrime`, `isPrimeUsingClass`, `isPrimeNotUsingClass`, indexed from 0 to 5
- Input size (`small` vs `large`): Small number (998244353) vs large number (6306436948373)

After running all tests, only two tests show stack overflow:
- `main1` + `byarg` + `large`, calling `isPrimeUsingClass` (`output-main1-mode4-large-byarg.txt`)
- `main1` + `byarg` + `large`, calling `isPrimeNotUsingClass` (`output-main1-mode5-large-byarg.txt`)
