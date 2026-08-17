# LADDER57 — matched-depth pairs, and a correction to the horizon rule

MEASUREMENT ONLY. The official `uhdm-cmp` is the sole judge of every gate here.
Earlgrey ladders are BUDGET/MAX-TRUNCATED, so only matched-depth pairs are read
and the horizon is respected.

`ctladder` built against the official UHDM install:

```
g++ -O2 -std=c++17 tools/probe/r10ladder1repro/ctladder.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ctladder
```

## THE RUNS

| ladder | rungs | stop | `int_typespec>integer_typespec` rungs |
|---|---:|---|---:|
| `lad_pris40`  `--max=40 --budget=300`   | 40 | MAX | **31** |
| `lad_pris90`  `--max=90 --budget=800`   | 90 | MAX | **65** |
| `lad_pris130` `--max=130 --budget=1500` | 130 | MAX | **85** |
| `lad_pat40`   `--max=40 --budget=400`   | 40 | MAX | **0** |

Every run stopped on MAX, not on the wall clock, so none of these numbers is a
budget artefact. The machine was NOT idle (other agents' compiles ran
throughout); MAX-stopped runs are why that does not matter here.

Pristine family census over the 130-rung ladder:

```
  85  int_typespec|VpiType|KIND:int_typespec>integer_typespec   <- THIS PASS
  13  logic_net|<rhs-null>|MISSING-OURS
  11  enum_const|<rhs-null>|MISSING-OURS
  10  constant|VpiType|KIND:constant>ref_obj                    <- earl56 R3/R5
   8  constant|VpiDecompile|O-EXTRA-PREFIX(')
   1  package|<rhs-null>|MISSING-OURS
   1  <null>|<lhs-null>|EXTRA-OURS
   1  constant|VpiDecompile|TEXT:#|#'b#
```

Patched, top 40:

```
  13  logic_net|<rhs-null>|MISSING-OURS
  10  constant|VpiType|KIND:constant>ref_obj
   8  enum_const|<rhs-null>|MISSING-OURS
   6  constant|VpiDecompile|O-EXTRA-PREFIX(')
   1  package|<rhs-null>|MISSING-OURS
   1  <null>|<lhs-null>|EXTRA-OURS
   1  constant|VpiDecompile|TEXT:#|#'b#
   0  int_typespec|VpiType|KIND:int_typespec>integer_typespec
```

## THE JOIN, AND WHY DEPTH MATTERS

`ladcmp57.py` joins on the GOLDEN site including its `#UhdmId`; `ladidx57.py`
splits "site absent" into CLEARED vs UNREACHED by pristine rung index.

| pristine side | CLEARED | NEW | KEPT |
|---|---:|---:|---:|
| `lad_pris40` (too shallow) | 31 | **25** | 9 |
| `lad_pris90` (still short) | 65 | **11** | 23 |
| `lad_pris130` (covers the patched walk) | 87 | **0** | 34 |

> **The `NEW = 25` and `NEW = 11` readings are pure HORIZON ARTEFACT and this
> file refuses to report them as findings.** Clearing 85 rungs lets the patched
> walk reach roughly pristine index 125 by its own rung 40, so a 40- or 90-rung
> pristine ladder simply has not been there yet. Read against a pristine ladder
> deep enough to cover the patched walk, **NEW = 0: the patched ladder
> introduces no rung and no FAMILY the pristine one did not already carry.**
> Reporting 25 "new defects" would have been the mirror image of earl56's
> "100 fixes" trap.

## THE 87 CLEARED, AND THE 2 THIS PASS REFUSES TO CLAIM

```
CLEARED (index <= horizon) = 87
   int_typespec|VpiType|KIND:int_typespec>integer_typespec   85   idx 1..123
   constant|VpiDecompile|O-EXTRA-PREFIX(')                    2   idx 127..129
UNREACHED (index > horizon) = 0
```

**85 are the pass's family** — every `DepthW` / `NWD` / `LfsrDw` /
`ExtResetReasons` cast rung the pristine ladder carried, and the patched ladder
carries **zero**.

**The 2 others are NOT fixes.** `tlul_adapter_sram.sv` 132:18 and 138:18, golden
`vpiDecompile "0"` against ours `"'0"`. The whole-dump path-normalised diff
between the two databases contains **ZERO `vpiDecompile` lines** — those objects
are byte-identical in both binaries — so they are UNREACHED by the patched
walk, not repaired.

That exposes a real limit of the instrument, recorded here for the next pass:
**`ladidx`'s horizon rule — "the last pristine site still present in the patched
ladder" — is not a sound ordering bound, because MASKING REORDERS THE WALK.** A
site at pristine index 127 can lie beyond a patched walk that still contains
index 130. When the ladder and the whole-dump diff disagree, **the whole-dump
diff wins.**

## CONTROLS

* rung 1 of `lad_pris40` is byte-for-byte `uhdm-cmp`'s head (`int_typespec(DepthW)
  @prim_fifo_sync.sv:16:27-16:27#985050` vs `integer_typespec@:72:45-72:51#235799`).
* rung 1 of `lad_pat40` is byte-for-byte the patched `uhdm-cmp` head
  (`constant@prim_fifo_sync.sv:131:29-131:38#291799` vs
  `ref_obj(PTR_WIDTH)#236039`) — and it is what `PREDICT_R0.txt` named in
  advance, ids included.
* the opposite-direction `constant@131:29 > ref_obj(PTR_WIDTH)` family is KEPT
  (10 rungs pristine, 10 patched): earl56's `directBound56` fence is intact and
  this pass moved nothing in it.
