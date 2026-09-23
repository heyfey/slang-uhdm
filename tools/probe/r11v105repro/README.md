# r11v105 — adversarial verifier arms for r11u105 (base 17b06e3d)

Verdict: CLEAN ACCEPT. The production diff ships unchanged. These are the
verifier's break arms, committed so the next pass does not have to rebuild them.

Run them on a COPY with the r11u103 runner (it writes into the arm dirs). The
golden is built once per arm by the pinned Surelog.
`GRID=<copy of grid> bash tools/probe/r11u103repro/rr103.sh <binary> <tag>`

| arm | face | pris → law (uhdm-cmp lines) |
|---|---|---|
| v01 / v02 | LAW A: a late top namesake shares a ported `leaf` with a LATER top `z` | SEGV / 1364 → **8 / 8** (R0 below) |
| v21 | the same shape on pass 102's LANDED instantiated road | 8 → 8 (both binaries) |
| v03, v20, v23 | controls: no collision / namesake declared first / `z` declared first | 0 → 0 |
| v04, v08, v16, v19 | top owns a nested module; depth-2 nested namesake; A+B+C together; two outers + unpacked param leaf | SEGV → 0 |
| v05 / v06, v07 / v07t, v11 / v11t, k15 / t_k15, k23 / t_k23 | a law arm against its no-collision twin: pass-82 drive fields, a function-call typespec, a program class/function, a ported program | law = twin (identical cmp output and distsec) |
| v10, v13 | a program declared after `dut` and instantiated; the same program instantiated by two parents | SEGV → 0 |
| v14, v15 | an interface with a parameter, a modport and a function; the same interface uninstantiated and parameterized | 596 / 254 → 0 |
| v09 | a nested PROGRAM in `sub` beside a file-scope top module of the same name | SEGV → SEGV (residue) |
| v12 | a program namesake under `--top dut` | 179 → 179 (residue) |
| v17, v18 | a ported nested module; `sub` reached only from a generate branch that is not taken | 0 → 0 |

**R0 (measured, NOT shipped).** `cand_repfix105.diff` is opt-in behind
`V11U93_REPFIX=1`. In `mergeSub103`, a subtree definition's representative is
moved to the entering root's instance when the current representative sits
under a design top that is walked LATER. With the switch on:

* v01, v02 and v21 read 0.
* Slot MOVED-WRONG is 0 and ENTRY AWAY is 0.
* No other arm moves, out of all 363 arms in the eleven grids.

It is not shipped because it also changes pass 102's landed road (v21).
