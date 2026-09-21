# r11v74 — adversarial verification of r11u74, and the ONE-HOP fix

Base commit `71490354`. Everything below was built and measured in this
verifier's own worktrees (`/tmp/wt_v11u74`, `/tmp/wt_v11u74pris`), with its
own frozen binaries, its own workdirs and its own grid. `results/*.csv` was
never touched.

| binary | md5 | what it is |
|---|---|---|
| pristine | `598195b29a98fb7ee3263d01d53861e6` | built here at `71490354`; **byte-identical** to the main tree's `build/slang-uhdm` and to the OPS pin (compared, not assumed) |
| implementer's patch | `6180aae9131eb1fb658f28a58044163a` | `/tmp/r11u74.patch` applied clean (`git apply` rc 0); reproduces the implementer's md5 bit for bit |
| shipped (verified) | `932d661da43b6720c400ccfbefd84b1e` | the same patch with the ONE-HOP fix of §2 |

---

## 1. WHAT WAS REPRODUCED BIT FOR BIT

- both binaries built `-j 2`, md5s taken separately; pristine == main tree == OPS pin;
- goldens `23 PASS / 0 FAIL` on all three binaries, `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**;
- u2r both modes on pristine and on the implementer's binary: **788 / 16 / 67** each;
- surelog pristine: **474/9 default, 469/8 testflags** — the committed baseline;
- `byteverify SELFCHECK=1` u2r, implementer's binary vs this verifier's own
  pristine workdir: **MOVERS 2 / 1608**, both `genvar_loop_decl_3`
  (default + testflags), SELFCHECK 1607/1608 — the implementer's predicted
  set exactly;
- the corpus move is **TO GOLDEN**, checked against the golden cache itself:
  golden's elaborated `work@gate.gen.y` Lhs ref carries
  `vpiActual -> logic_net (work@gate.y)`; pristine wrote
  `integer_var (work@gate.gen.y)`, patched writes golden's object. The row was
  `CMP_EQUAL` before and stays `CMP_EQUAL` (committed baseline
  `results/golden_uhdm2rtlil.csv:293` / `:1164`);
- the brief's LAW A premise is refuted, as the implementer said: the committed
  baseline carries `struct_param_field_shift,{default,testflags},CMP_EQUAL`
  (`results/golden_uhdm2rtlil.csv:739`, `:1610`, `results/gate_uhdm2rtlil.csv:739`)
  and the row is `CMP_EQUAL` on all three binaries. **0 corpus rows convert.**

---

## 2. THE BREAK — a pristine-RIGHT cell the patch made WRONG, and the fix

The implementer's LAW B walked OUTWARD from the writing scope and bound the
**first** namesake it met, at any depth ("the NEAREST wins"). Golden does not
climb.

### 2a. `v9_hops` — three nesting levels, one namesake per level

`L1 (gen-for) > L2 (gen-if) > L3 (gen-if)`, every target declared in `L3`,
every Rhs the same literal, so the only thing that can vary is `vpiActual`:

| cell | namesake lives in | golden | pristine | implementer | shipped |
|---|---|---|---|---|---|
| `L3.m3` | `L2` — ONE scope out | `logic_var work@dut.L1[0].L2.m3` | none | golden's | golden's |
| `L3.n3` | `L2`, a NET | `logic_net work@dut.L1[0].L2.n3` | none | none (netMap miss) | none — residue |
| `L3.m2` | `L1[0]` — TWO scopes out | **none** | none | `work@dut.L1[0].m2` **WRONG** | none |
| `L3.m1` | the module body — THREE out | **none** | none | `work@dut.m1` **WRONG** | none |
| `L5.u1` | an UNNAMED gen block, one out | `logic_var work@dut.L1[0].genblk2.u1` | none | golden's | golden's |

### 2b. `v1_nearest` — the same question in two levels

`ga[i].x` (target in `ga`, namesake in the module body) binds `work@dut.x` in
golden; `ga[1].gin.x` (target in `gin`, namesake in `ga[1]` AND in the module
body) binds `work@dut.ga[1].x` — the immediately enclosing one; and
`ga[1].gin.y` / `.z`, whose only namesakes are in the module body two scopes
out, carry **no actual at all** in golden. Pristine carried none either. The
implementer's binary bound both of them.

**SCORE ON THOSE TWO ARMS**, ours-only dump lines (lines we write that golden
does not): pristine `6` / `20`, implementer `10` / `24`, shipped `6` / `20`.
It is judge-visible surface: `cont_assign::Compare`
(`UHDM/build/generated/src/cont_assign.cpp:124`) reaches `ref_obj::Compare`
(`ref_obj.cpp:150`) which reads `Actual_group`, and `BaseClass::Compare`
(`BaseClass.cpp:170`) compares `VpiType` first — a null/non-null pair is a
head (`SafeCompare`, `BaseClass.h:187-193`). `v1_nearest` on the implementer's
binary: `cmp_rc 255`, head `LHS: <null>` / `RHS: logic_var (work@dut.y)` —
**ours wearing an object golden does not have.**

### 2c. THE FIX (`src/ModuleEmit.cpp`, `genCaLhsNamesake74`)

The walk now examines **exactly one searchable scope** — the first
`GenerateBlock` or `InstanceBody` outside the writing scope, stepping over the
`GenerateBlockArray` wrapper slang puts between a gen-for body and its parent
(that wrapper is not a scope in UHDM either) — and returns its answer, hit or
miss. Nothing else changed; both laws keep their switches.

After the fix `v1_nearest` and `v9_hops` are back to golden on those four
cells, and `v1_nearest` **CONVERTS** (`cmp_rc 255 -> 0`), which it did not on
the implementer's binary.

---

## 3. THE GOLDEN GRID (9 verifier arms x real v1.87 goldens; `golden_rc=0 ours_rc=0` on every arm)

| arm | what it asks | result |
|---|---|---|
| `v1_nearest` | does the walk climb? | **NO** — fix; CONVERTS |
| `v2_kindns` | namesakes that are a function, a typedef, an instance, the block itself, an unpacked array, a struct var | golden binds the two that ARE signals and nothing else; shipped **CONVERTS** (`255 -> 0`) |
| `v3_order` | namesake declared BELOW the block; an UNNAMED enclosing block; a namesake only in a FALSE gen-if arm | order-blind (golden binds the late `later`), the unnamed block IS a home, the dead arm is not; **CONVERTS** |
| `v4_lhsshape` | part-select / element / member / concat Lhs, and namesakes of a different width | the law declines every non-plain Lhs; the width rows bind and match golden |
| `v5_inst` | the same body elaborated twice + a PARENT-only namesake | per-instance bind, parent not reachable; **CONVERTS** |
| `v6_ifacepkg` | interface generate scope, wildcard-imported package namesake | interface home served; the package namesake is golden-bound and ours is not — residue R2 |
| `v7_foldshape` | LAW A: gen-scope localparam base, NET Lhs, the same member read twice, and the cell where BOTH laws fire | joint cell byte-identical to golden (folded BIN + namesake bind); gen-scope localparam base is a residue |
| `v8_foldinst` | LAW A across two elaborations with different parameter values | `64` and `128` folded per instance, exactly golden — no cross-instance leak |
| `v9_hops` | the hop count | ONE — fix |

The implementer's eight arms were re-run on all three binaries: identical
readings to its report (`a1` `cmplines 33 -> 15`, `b1` and `b3` `cmp_rc 255 ->
0`, `b4` `cmp_rc 0` on pristine and unmoved). No arm's ours-only line count
rises on the shipped binary; `b4_nonamesake` is byte-identical on all three.

**SWITCHES.** `R11U74_OFF=1` reproduces the pristine database **byte for byte
on all 17 arms**. Each switch drops its own law alone: on LAW-A-only arms
`R11U74_FOLD_OFF=1` == pristine and `R11U74_BIND_OFF=1` == shipped; on
LAW-B-only arms the mirror.

---

## 4. RESIDUES THIS VERIFIER ADDS (ranked)

1. **The gen-scope NET namesake is found but not bound** (`v9_hops` `n3`,
   `R11U74BIND ... bound=0`): the namesake symbol resolves, `netMap` has no
   object for a net declared in an enclosing GENERATE scope, so the cell stays
   unbound where golden binds `logic_net work@dut.L1[0].L2.n3`. Pristine also
   left it unbound, so it is a MISS, not a regression — and it is the cheapest
   next cell on this ground.
2. **A gen-scope-declared localparam as the fold base** (`v7_foldshape`
   `gl_loc`): golden folds `GLOC.n` to `BIN:…100000000`, we keep the symbolic
   `hier_path (GLOC.n)`. LAW A's base lookup only sees module/package
   parameters.
3. **The wildcard-imported package namesake** (`v6_ifacepkg`): Surelog homes
   the package variable as `work@dut.pkns` and binds gen-scope cells to it;
   we decline (r11u71's R2, measured here on a second shape).
4. **A concat Lhs in a generate scope carries actuals we invent**
   (`v4_lhsshape` `{cat0, cat1}`): PRE-EXISTING on both binaries, golden has
   none — a `bindGenLocal9` cell, not this pass's.
5. The implementer's R1 (a target declared OUTSIDE the writing scope) stands
   unchanged and is confirmed judge-visible here.

---

## 5. THE GATES ON THE SHIPPED BINARY (`932d661da43b6720c400ccfbefd84b1e`)

1. Built `-j 2`, md5 separate; pristine built here == main tree == OPS pin.
2. Goldens **23 PASS / 0 FAIL**; `/bin/false` **0 PASS / 23 FAIL**.
3. **u2r both modes 788 / 16 / 67.** Row-join vs the committed gate PASS, vs
   the committed both-mode golden CSV **0 of 1743 rows differing**, vs this
   verifier's own pristine sweep PASS in both modes.
   `byteverify SELFCHECK=1` vs own pristine: **MOVERS 2 / 1608**, SELFCHECK
   1607/1608 — `genvar_loop_decl_3` default and testflags, the predicted set,
   with the SAME database md5s the implementer's binary produced
   (`261801607985`, `6ac5063529f9`). Attribution: 4 dump lines per mode,
   `integer_var (work@gate.gen.y)` / `(work@gold.gen.y)` ->
   `logic_net (work@gate.y)` / `(work@gold.y)`, **which is the object golden
   carries** (read off the golden cache). Row stays `CMP_EQUAL` both modes.
4. **surelog `--mode both` 474/9 default, 469/8 testflags** — identical to the
   committed baseline and to this verifier's own pristine sweep. Whole-row
   join vs committed differs on 4 rows, every one environment and every one
   present on the PRISTINE binary too: `Earlgrey_0_1`'s dump COLUMN blanking
   in both modes (the documented `uhdm-dump` timeout draw; status stays
   `CMP_EQUAL`) and `LowMemLib` / `LowMemPkg` carrying the workdir path inside
   a `SURELOG_FAIL` string. `byteverify SELFCHECK=1` vs own pristine:
   **MOVERS 3 / 960**, SELFCHECK 959/960 — `MiniAmiq/default`,
   `SeqDriver/default`, `SeqDriver/testflags`, each **exactly 4 order-blind
   lines, every one a `UINT:<n>` + `vpiDecompile:<n>` pair**: the documented
   UVM macro-buffer line-number class. No `vpiActual` and no folded
   `constant` among them; the whole UVM family stays `CMP_EQUAL`.
5. **Canary database byte pins, fix vs own pristine, all SAME:** `SVSwitch
   4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`,
   `YosysOldOr d68e0796d62c`, `BlackParrotComplex` both modes, and
   `Earlgrey_0_1` **default `8bdf25272e08` / testflags `59d0ee6d10c3`** —
   the OPS pins exactly.
   `canaries.sh` fix vs own pristine `ok=52 changed=0`; u2r `ok=8 changed=0`;
   `ctcan2` PASS on both corpora; `canaudit audited=29 UNCOVERED=0
   FENCE-BREACH=0 PASS`. No fenced name appears anywhere in the patch outside
   `canaudit.sh`'s own `FENCED=` line.
6. **Binary path audit:** u2r 1742/1742 `cmds.txt` name the frozen binary on
   both sides; surelog 1531 of 1581 do and the other 50 are Surelog-side
   failures that never invoked an exporter. **No `cmds.txt` in any of the four
   workdirs names a main-tree or worktree binary.**
7. **SCORE: MOVED-WRONG 0, AWAY-GOLDEN 0, TO-GOLDEN 4** (the two corpus
   databases, 2 cells each), both corpora, both mode columns. Grid: 17 arms,
   **7 `cmp_rc 0`** on the shipped binary against 6 on the implementer's and 1
   on pristine, **0 arms regress**, and on no arm does the ours-only line
   count rise. `results/*.csv` untouched.

---

## 6. HOW TO RE-RUN

```bash
GRID=<this dir>/grid bash vv74.sh <binary> <tag>     # golden + ours + cmp per arm, every rc recorded
GRID=<this dir>/grid bash vscore.sh                  # gold-only / ours-only dump distance per arm
```

`vv74.sh` regenerates the golden with the pinned Surelog per arm per tag and
records `golden_rc` and `ours_rc` for every arm; an arm whose compile fails
teaches error recovery, not golden. No corpus test is ever dispatched from
here — every arm is its own `dut.sv`.
