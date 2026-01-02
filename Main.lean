import Mini
import Lean

open Lean Meta Elab Term

unsafe def elabAndEval (α : Type) (stx : Syntax) : TermElabM (Expr × α) := do
  let tm ← elabTerm stx none
  synthesizeSyntheticMVarsNoPostponing
  let tm ← instantiateMVars tm
  let ty ← inferType tm
  -- IO.println s!"{tm}"
  let res ← evalExpr α ty tm
  pure (tm, res)

-- The following code is inspired by `https://leanprover.zulipchat.com/#narrow/channel/270676-lean4/topic/Trouble.20parsing.20Lean.20code.20from.20string/`
unsafe def parseAndEval (a : Fin 6) (code : String) : IO Bool := do
  initSearchPath (← findSysroot)
  enableInitializersExecution
  let imports := #[`Lean, `Mini]
  let env ← importModules (imports.map (Import.mk · false true false)) Options.empty
    (leakEnv := true)
    (loadExts := true)
  let (ioResult, _) ← Core.CoreM.toIO (ctx := { fileName := "<CoreM>", fileMap := default }) (s := { env := env }) do
    let .ok stx := Parser.runParserCategory (← getEnv) `term code "<stdin>"
      | return none
    -- IO.println s!"Parsed syntax: {stx}"
    MetaM.run' do
      TermElabM.run' do
        match stx with
        | `(($stx1:term, $stx2:term)) =>
          -- IO.println s!"Tuple detected: {stx1}, {stx2}"
          IO.println "argument case"
          let (tm1, res1) ← elabAndEval Bool stx1
          let (tm2, res2) ← elabAndEval Nat stx2
          let tminst ← synthInstance (mkAppN (mkConst ``MyClass) #[tm1, tm2])
          let tyinst ← inferType tminst
          let res3 ← evalExpr (MyClass res1 res2) tyinst tminst

          match a with
          | 0 => return some <| @foo res1 res2
          | 1 => return some <| @fooUsingClass res1 res2 res3
          | 2 => return some <| @fooNotUsingClass res1 res2 res3
          | 3 => return some <| @isPrime res2
          | 4 => return some <| @isPrimeUsingClass res1 res2 res3
          | 5 => return some <| @isPrimeNotUsingClass res1 res2 res3
        | _ =>
          -- Directly parse and eval the call
          IO.println "call case"
          let (_, res) ← elabAndEval Bool stx
          return some res

  let some ioResult := ioResult | throw (IO.userError s!"Failed to parse input")
  return ioResult

def main1 (xs : List String) : IO Unit := do
  -- Read input from `stdin`
  let stdin ← IO.getStdin
  let code ← stdin.readToEnd
  let a := Fin.ofNat 6 (xs[1]?.bind String.toNat? |>.getD 0)
  let result ← unsafe parseAndEval a code
  IO.println s!"{result}"

def main2 (xs : List String) : IO Unit := do
  -- Read the number from `xs[2]`
  let a := Fin.ofNat 6 (xs[1]?.bind String.toNat? |>.getD 0)
  let res2 := xs[2]?.bind String.toNat? |>.getD 3
  let test := match a with
    | 0 => foo true res2
    | 1 => fooUsingClass true res2
    | 2 => fooNotUsingClass true res2
    | 3 => isPrime res2
    | 4 => isPrimeUsingClass true res2
    | 5 => isPrimeNotUsingClass true res2
  IO.println s!"{test}"

def main (xs : List String) : IO Unit :=
  let b := xs[0]?.bind String.toNat? |>.getD 1
  if b == 1 then main1 xs else main2 xs
