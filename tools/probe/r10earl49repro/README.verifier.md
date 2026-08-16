# r10earl49 — verifier notes

Three things went wrong inside this pass and were fixed **before** anything
landed. All three are recorded here because a silently-corrected mistake is
indistinguishable from one that was never made.

---

## V1. The first cut of the law OVER-FIRED on 32 cells, and the census prediction is what caught it

`§ caOperandScanRead49`'s first implementation recursed into **every**
operation operand once the pre-scan completed:

```cpp
if (!constantOperands) return;
for (auto* op : opnds)
    if (op && srlgIsOp49(*op))
        srlgCaOperandScan49(*op, names, depth + 1);   // WRONG
```

That is right for every binary, unary, comparison and concat arm — they reduce
all their operands unconditionally — and **wrong for the ternary**, whose arm
(`UHDM/templates/ExprEval.cpp:3763`) reads

```cpp
expr* cond = reduceExpr(operands[0], invalidValue, inst, pexpr, muteError);
int64_t condVal = get_value(invalidValue, cond);
if (invalidValue) break;                       // <-- NEITHER BRANCH REDUCED
the_val = reduceExpr(operands[condVal ? 1 : 2], localInvalidValue, ...);
```

The Earlgrey witness is `prim_filter_ctr.sv:54-56`:

```systemverilog
assign diff_ctr_d =
    (filter_i != filter_q)           ? '0       :
            (diff_ctr_q == CYCLESM1) ? CYCLESM1 :
                (diff_ctr_q + 1'b1);
```

The top-level ternary's operands are `(operation, constant, operation)`, so
nothing stops the pre-scan — but its condition reads two **variables** and
never folds, so the nested ternary holding `CYCLESM1` is never reduced.

| | first cut | landed |
|---|---|---|
| Earlgrey/default cells moved | **33** | **1** |
| design-wide census disagreements (golden vs ours) | 79 → **141** | 79 → **77** |
| cells that ENTERED the disagreement set | **32** | **0** |

All 32 were one family: `work@top_earlgrey.u_gpio.gen_filter[0..31].filter`,
every instance of `prim_filter_ctr`.

**The mechanism that caught it was `CENSUS_PREDICT.txt`** — written from the
PRISTINE pair before the patched Earlgrey run, predicting *exactly one* moved
cell. The cmp head cleared in both cuts and the row advanced identically in
both; a "head cleared, gates green" reading would have shipped 32 regressions,
because the u2r and surelog corpora contain no `prim_filter_ctr`. Only the
prediction disagreed with the measurement.

Fixed by `f1_earl49.sv`, which fences **both** halves of the ternary arm
against real Surelog:

| cell | condition | golden | pristine | patched |
|---|---|---|---|---|
| `CYCLESM1` | `(filter_i != filter_q)` — variables, never folds | LOCATED | LOCATED | LOCATED ✓ |
| `TAKEN` | `(Cycles > 0)` — folds, taken branch IS entered | BARE | **LOCATED ✗** | **BARE ✓** |

`TAKEN` matters: it shows the taken-branch recursion is a real law of golden's
and not a guard bolted on to suppress the over-fire. The pristine binary got
that cell wrong; the landed one gets it right.

---

## V2. `sweeps49.sh`'s binary read-back had been "fixed" into silence

r10earl46's R9 recorded that the read-back line grepped the **first**
`*slang-uhdm` token on the command line, which is the GOLDEN CACHE path, not
the binary. r10earl48 replaced it with

```sh
grep -oE '/[^ ]*/build/slang-uhdm' "$c" | head -1
```

which assumes the binary lives in a directory called `build/`. This pass runs
`/tmp/r10earl49_pat.bin` and `/tmp/r10earl49_pris.bin` (copies, asserted by
md5), so the pattern matched **nothing** and every sweep printed

```
   cmds.txt binary:
```

— an empty string, which reads exactly like a passing check. The standing rule
says *"verify via the workdir's cmds.txt"*; a check that silently returns
nothing does not verify anything. Fixed to read the `slang:` line's own first
token, whatever it is called:

```sh
[ -n "$c" ] && echo "   cmds.txt binary: $(awk '/^slang:/{print $2; exit}' "$c")"
```

and the binary each sweep actually invoked is now printed and quoted in the
report.

---

## V3. TWO `sweeps49.sh` PROCESSES RAN CONCURRENTLY — detected, killed, state wiped, re-run

`sweeps49.sh`'s own header states the rule it exists to enforce:

> Sequential, never concurrent: concurrent sweeps have a documented
> SURELOG_FAIL detail-row race.

The first launch was backgrounded; its wrapper shell exited and was reported as
"completed (exit code 0)" while the sweep itself was still running the surelog
corpus. Reading only the wrapper's status, a second `sweeps49.sh` was launched
against **the same CSV directory and the same workdir root**. `ps` showed both
alive:

```
1487075 bash ./sweeps49.sh ...            (still on surelog/default)
1564309 bash ./sweeps49.sh ...            (surelog/default again)
1564319 python3 verify_golden.py --corpus surelog --mode default \
          --out /tmp/r10earl49_csv/surelog_default_pat.csv \
          --workdir /tmp/r10earl49_wdroot/surelog_pat --jobs 2
1567751 python3 verify_golden.py --corpus surelog --mode testflags \
          --out ... --workdir /tmp/r10earl49_wdroot/surelog_pat --jobs 2
```

Remediation, in this order, because a partially-written CSV is worse than none:

1. `kill -9` every `sweeps49.sh` and `verify_golden.py`, then `ps` until the
   count is **0** (the first two `pkill` rounds left survivors — the count was
   re-read, not assumed);
2. `rm -f /tmp/r10earl49_csv/surelog_*` and
   `rm -rf /tmp/r10earl49_wdroot/surelog_*` — every artifact either process
   could have touched;
3. re-launch **one** `sweeps49.sh` with `SWEEP_CORPORA=surelog` (a filter added
   here so the already-clean uhdm2rtlil sweeps are not re-run into the same
   directory), confirmed `verify_golden.py` process count is exactly **1**, and
   waited for `ALL_SWEEPS_DONE`.

The four uhdm2rtlil sweeps completed **before** the second launch and were
never concurrent with anything; their CSVs were kept and are the ones judged in
the report. Only the surelog corpus was re-run, from a wiped state.

**Lesson for the next pass, and it is an ops law, not an anecdote:** a
background-task "completed" notification reports the *wrapper*, not the work.
Before treating a sweep as finished, require its own terminal marker
(`ALL_SWEEPS_DONE`) **and** `ps -ef | grep -c '[v]erify_golden.py'` = 0. This
pass's `sweeps49.sh` prints the marker; nothing else may be used as the signal.
