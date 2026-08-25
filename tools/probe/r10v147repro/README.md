# r10v147 — the ADVERSARIAL VERIFICATION of r10uvm147 (§ `selChainElemShapeIsSyntactic147`)

**VERDICT: ACCEPT, production unchanged.** Base commit `c67afc7`. The verifier
rebuilt both binaries from scratch in its own worktrees, re-ran every gate, and
attacked the law with **eight further grids** covering the position, home,
symbol-kind, index-shape and constant-context faces the implementer's five did
not reach. **No pristine-right → patched-wrong cell was found on any legal SV,
in either view, in any arm.** One NEW residue was characterised (R-V1 below);
it is wrong before and wrong after, and its corpus reach today is zero.

## 1. What reproduced BIT-FOR-BIT

Both binaries were rebuilt from `c67afc7` (+ the patch) with an independent
`cmake` configure, `-j 2`:

| | md5 |
|---|---|
| pristine | `055ba5e17d0118cad5274d6a24a34f1e` |
| patched  | `d87a326362a1c93405a6fce3e4dd28d0` |

— identical to the implementer's, so every number below is measured on the same
bytes it claims to be about. The applied worktree also re-emits the patch
byte-for-byte (`git diff HEAD` md5 `f1844f1b7b582638d4735cd407e19845`).

Reproduced exactly, from the verifier's own sweeps and its own pristine control:

* goldens **23/0** for BOTH binaries; `SLANG_UHDM=/bin/false` **0/23**.
* uhdm2rtlil **679 / 50 / 2** in both modes under both binaries;
  `ct8rows` PASS whole-row against the committed baseline AND against the
  verifier's pristine control, testflags AND default.
* surelog corpus, `--mode both`: **0 differing rows over 1588**, whole row,
  dump column included, against the committed baseline and against the
  verifier's pristine control. Status histograms identical. **NO ROW
  CONVERTED**; `results/*.csv` only READ.
* every `cmds.txt` audited by BINARY PATH: 1523/1573 surelog and 1458/1462 u2r
  rows name the patched binary, **0 name any other**; the pristine workdirs
  likewise name only the pristine binary.
* `byteverify SELFCHECK=1`: **MOVERS 2 / 956** and **0 / 1358**,
  `PATH_SETS_IDENTICAL` both. The verifier's run flipped no Scoreboard coin, so
  the mover set is EXACTLY the a-priori predicted set — the predictor, rebuilt
  from source and run on the verifier's PRISTINE databases, returns
  `2` candidates over 956 and `0` over 1358, naming `76967:20 value[idx]` and
  `77065:10 value[idx]` twice each.
* heads: SeqDriver 62/62, SimpleUVM 62/62, Scoreboard/default 62, MiniAmiq
  62/62, Earlgrey_0_1 64/64, Rggen 0 — **all unchanged and their cmp logs
  byte-identical between the two binaries**; **BuildUVMPkg 174 → 68 both
  modes**, one `^LHS:` per run, the two patched heads byte-identical.
  All 12 committed `head_pris_*`/`head_pat_*.cmp` logs reproduced byte-for-byte.
* the head OBJECT is cleared, not shrunk: pristine's head is the `var_select` at
  `uvm_pkg.sv:76967:20-38`; patched's is a `func_call uvm_root::get` at
  `29217:10-18` — a different object, the implementer's R0.
* census over the UVM rows, calibrated golden-vs-golden first (9 self-joins → 0
  wrong, and a re-restore is byte-stable): **BuildUVMPkg DIFFER 4 → 0**
  (996 → 1000 shared-equal), every other row byte-for-byte unchanged.
* canaries `ok=52` / `ok=8` `changed=0`; `ctcan2` PASS both; `canaudit`
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`; SVSwitch `4842211c4030`,
  YosysVerx `6ccda350c24a`, InterfaceModPort / BlackParrotComplex / YosysOldOr
  byte-identical in both modes.
* mover attribution, sorted path-normalised id-stripped whole-dump diff:
  66 removed / 112 added, every changed object at `uvm_pkg.sv` line 76965,
  76966, 76967, 77063 or 77065 and nowhere else. Subtree vs golden: **site
  76967 IDENTICAL**; site 77065 differs in ONE dump-only `vpiParent` line.

## 2. The verifier's WIDE BOUNDARY GATE

Run over a COPY of the WHOLE probe tree plus six of the verifier's own grids
(`v147_h/i/j/k/p/s`; `v147_x`/`v147_y` were written afterwards) — a SUPERSET of
the implementer's 4184-file list:

```
LISTED=4190 PROCESSED=4190 PRODUCED_DBS=4045 MOVED_ARMS=11 RC_DIFFS=0
```

The 11 movers are this pass's five grids and six of the verifier's own — the
positive control that proves the gate can see — and **nothing else**. No
`r10uvm77-79`, `82-91`, `84/85`, `89`, `92`, `113`, `143`, `144`, no
`r10buvm3-15`, no `r10sd8-12` arm moved. `RC_DIFFS=0`: the 14 pre-existing
`--elabuhdm` segfaults fire identically under both binaries.

## 3. BREAKING THE LAW — eight further grids

Same instrument as the implementer (its `ct147cen --sel` + `join147.py`,
rebuilt from source; key = `span | hier_path VpiName`, payload = the element
SHAPE SIGNATURE; `VpiFullName` never in key or payload), Surelog golden in
BOTH views, both frozen binaries, every child rc printed.

| grid | the faces it adds | DEF wrong | ELAB wrong |
|---|---|---|---|
| `v147_p.sv` | **POSITION**: call argument (the corpus shape itself), function-call argument, concatenation, replication, cast operand, ternary arm, comparison operand, `case` expression, builtin `push_back` argument, unary reduction, `$display` argument, `foreach` LVALUE, both operands of an add, property LVALUE, `return` expression — each with its LOCAL-VARIABLE twin | 18 → **0** | 36 → **0** |
| `v147_h.sv` | **HOME**: `$unit`-scope class, class declared INSIDE a module, PROGRAM block (initial + function), function AND task inside an INTERFACE, module TASK with a formal receiver, module function with a `ref` formal, 1–3 instances | 8 → **0** | 16 → **2** (pre-existing, unmoved) |
| `v147_k.sv` | **SYMBOL KIND**: package `parameter` (not localparam) base, two different specializations of a parameterized class, `const ref` STRUCT formal, static local as target, struct-typed class property, handle→struct-member chain, `automatic` variable inside a `fork`, imported package parameter | 13 → **0** | 31 → **0** |
| `v147_i.sv` | **ITERATOR** symbol kind (`item` inside a `.sum with (…)` clause), queue and fixed-array receivers | 2 → **0** | 4 → **0** |
| `v147_j.sv` | **INDEX SHAPE**: function CALL index, member-select index, ternary index, doubly-nested select index, STRING associative key, enum-cast index, `-:` on formal / struct / localparam bases, concatenation as the part-select base, member chain + call index — each with a LOCAL-VARIABLE twin | 25 → **18** (name residue) | 50 → **36** |
| `v147_x.sv` | FOUR element steps, `$bits` argument, `for`-loop init, `always_comb`, `always_ff`, assertion property, loop-variable index, parameterized-width packed member | 7 → **0** | 14 → **0** |
| `v147_s.sv` | **CONSTANT-FOLD risk**: struct localparam/parameter base in a localparam initializer, a parameter OVERRIDE argument, a fully-constant procedural read, a GENVAR index in a generate `assign` — with module-VARIABLE controls | 24 → **16** | 32 → **20** |
| `v147_y.sv` | where golden uses the SPLIT element shape: localparam initializer vs default argument vs variable initializer vs procedural vs `case` item vs generate condition | 12 → **7** | 17 → **8** |

**Transition audit over all 13 arms (the implementer's five re-measured plus
these eight) × both views: TO-GOLDEN 444 / AWAY-GOLDEN 0 / STILL-WRONG 136 /
UNMOVED-OK 206.** Not one cell went from agreeing with golden to disagreeing.

Facts the grids establish that the implementer's write-up asserted but did not
measure:

* **the LOCAL-VARIABLE controls never move.** The order-blind whole-dump diff
  of every grid touches only the source lines carrying the newly-admitted base
  kinds; `v147_p` lines 41–52 (seven local-variable twins), `v147_h` lines
  61–63 (module-variable receivers), `v147_s` lines 37–38 and `g147_c` line 56
  are untouched, byte for byte.
* **R1 is real.** In `g147_c` the modport-port cell (line 42) and the
  interface-instance cell (line 54) are byte-identical before and after: the
  `ArbitrarySymbol` / `HierarchicalValue` road is genuinely not reached.
* **no constant-fold regression.** A FULLY CONSTANT procedural read of a
  struct localparam (`o = LS.arr[0][15:8]`) is a `hier_path` in golden too, and
  the patched shape is EXACTLY golden's. Parameter-override arguments produce
  no `hier_path` on either side.
* **the new rows are golden's rows.** In `v147_j` the patch adds three
  `hier_path`s for nested-select indices (`fa.s.arr[0]`, `fa.ix`, `fa.ix[i]`);
  golden has all three, and the local-variable twin already had them pristine.
* the `refCollector->insert` the widened gate now reaches for new symbol kinds
  is **inert**: `processRefs` / `instRefs` / `parentRefs` are written and never
  read anywhere in the emitter.

## 4. R-V1 — the NEW residue this verification found

**In a PARAMETER-ASSIGNMENT initializer and in a GENERATE CONDITION, golden
uses the SPLIT element shape for the very same written chain that it fuses into
one `var_select` in a procedural statement.** The law as stated — "the shape is
decided by the WRITTEN SELECT CHAIN alone" — is therefore true of the roads the
pass converts and INCOMPLETE across compile roads.

Measured (`v147_y.sv`, golden, both views), for the identical text
`PY.arr[0][15:8]` on a struct localparam base:

| context | golden's element list | ours (patched) |
|---|---|---|
| `localparam logic [7:0] Y1 = PY.arr[0][15:8];` (pkg **and** module) | `ref_obj/PY > bit_select/arr{constant}@MID > part_select/<anon>@TRAIL` | `ref_obj/PY > var_select/arr{constant,part_select}@TRAIL` |
| generate condition `if (PY.arr[0][15:8] == …)` | the same SPLIT | `ref_obj/PY > bit_select/arr{constant}@TRAIL` — the trailing range is LOST; **byte-identical pristine and patched**, a wholly separate builder this pass does not touch |
| default argument value | fused `var_select` | **matches** |
| variable initializer `logic [7:0] v = …;` | fused `var_select` | **matches** |
| procedural `o = …;` | fused `var_select` | **matches** |
| `case` ITEM | fused `var_select` | **matches** |

So the discriminator is not "constant expression": a variable initializer and a
`case` item both fuse. It is the **param_assign / elaboration road**.

**This is not a regression.** Pristine emits the flat
`part_select/arr[0]{part_select}` for the same cells — wrong in a different
way; `AWAY-GOLDEN` is 0 on both `v147_s` and `v147_y`. And the population is
reachable ONLY through a base kind the pristine gate refused, so it did not
exist as a *var_select* population before.

**Corpus reach today: ZERO.** The whole-corpus sweeps move exactly two
databases and both are attributed line-by-line to `uvm_pkg.sv:76967/77065`;
`ct8rows` is 0 differing rows over 1588 and over 731×2. Ranked below R1.

## 5. Residues confirmed as the implementer stated them

* **R1** — the `ArbitrarySymbol` / `HierarchicalValue` base (interface
  instance, modport port) still flattens. Verified untouched, corpus reach 0.
* **R2.1** — the LVALUE branch's blanket `suppressConstParent = true` leaves the
  constant nested in `i0*8` unparented. Verified as the single dump-only line
  by which site 77065's subtree differs from golden's; `vpiParent` is read by no
  generated `Compare`.
* **R2.2** — the nested-select index NAME (§ `hpTrailSelIdxDecompiled89`
  convention B). Verified PRE-EXISTING: in `v147_j` the hier_path `VpiName`
  text is byte-identical pristine and patched for every cell, and the
  LOCAL-VARIABLE twins carry the identical residue. It is what `v147_j`'s
  18 DEF / 36 ELAB "wrong" cells are — key-only rows, shapes equal.

## 6. FILES

| file | what it is |
|---|---|
| `v147_p/h/k/i/j/x/s/y.sv` | the eight verifier grids |
| `ARMS.r10v147.txt` | the census score + transition audit of all 13 arms, both views |
| `GATES.r10v147.txt` | the verifier's own gate battery |
| `MEASUREMENTS.r10v147.txt` | heads, prediction, mover attribution, corpus census, wide boundary |

The scorer, arm driver, boundary driver, predictor and gate scripts are
`tools/probe/r10uvm147repro/`'s, rebuilt from source by the verifier; they are
not duplicated here.
