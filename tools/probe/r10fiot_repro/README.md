# r10fiot — the purpose-built goldens behind FuncIoTypespec's four laws

Each `a*.sv` is a multi-arm file: ONE module per shape, names unique per module
so a minted net or a stamped typespec in one arm cannot be confused with
another's.  Run against Surelog's DEFAULT-mode args (`-parse -mt 0 -mp 0`, no
`-nobuiltin` — that is what `verify_golden.py --mode default` gives the golden
side) and diff the CMP-relevant projection:

    SLANG_UHDM=$PWD/build/slang-uhdm bash tools/probe/r10fiot_repro/run.sh \
        tools/probe/r10fiot_repro/a1.sv
    python3 tools/probe/r10fiot_repro/tab.py a1      # io_decl typespec table
    python3 tools/probe/r10fiot_repro/argts.py \
        /tmp/r10fiot_arm/a9/gn.txt /tmp/r10fiot_arm/a9/on.txt   # call-arg table

`a1`/`a2` need golden only (slang rejects `m5`/`m7`/`n3` — an undeclared range
bound is an error to slang and an implicit net to Surelog, which is the point).

| file | what it isolates |
|---|---|
| a1 | which identifier POSITION mints the module implicit wire (§ fnLocalParamRangeNet) |
| a2 | the dangling-vs-mint boundary: fn-local param INITIALIZERS, module-param shadowing, one net per name |
| a3 | bare-formal io_decl typespec by spelling x reach (§ bareFormalTsReached) |
| a4 | ...signing, package/task scope, procedural vs continuous call |
| a5 | how far the evaluator's descent travels through called bodies |
| a6 | where the descent ABORTS (foldable if, case, statements after an abort) |
| a7 | loops: for/while/repeat over body-local state vs a formal-dependent bound |
| a9 | which call ARGUMENT carries the formal typespec (§ evalReachedCallees / drainBodyOpArgTs) |
