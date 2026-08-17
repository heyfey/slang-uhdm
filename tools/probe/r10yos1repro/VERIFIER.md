# r10yos1 — ADVERSARIAL VERIFICATION (vyos1)

Fresh worktrees `/tmp/wt_vyos1` (patch applied) and `/tmp/wt_vyos1pris`
(pristine), both at **4df4bab**; both binaries built here, `-j 2`, md5 taken
separately.

## VERDICT: law CONFIRMED, headline numbers REPRODUCED BIT-FOR-BIT, patch
## ACCEPTED **only with the two fixes below** — the implementer's binary
## SEGFAULTS on a dotted top that instantiates an interface, and drops the
## def-view LowConn actuals of a child shared with a plain top.

## 1. Everything reproduced

| claim | implementer | measured here |
|---|---|---|
| base binary md5 | `4220e4f818406b3c91323967eb59db89` | **same** |
| patched binary md5 | `c4831e67ff24a6433043ede119729997` | **same** |
| goldens / negative control | 23/0 and 0/23 | **same** |
| u2r both modes, both binaries | 679/50/2 | **same**; `ct8rows` 0 differing rows for the testflags slice vs committed `gate_uhdm2rtlil.csv` (base AND patched) and 0 over all 1462 rows patched-vs-base |
| surelog baseline vs committed CSV | 0 differing rows / 1588 | **same** |
| surelog patched | exactly 2 rows: `YosysVerx,{default,testflags}` `CMP_NOTEQUAL`→`CMP_EQUAL` + `dump match` | **same rows, same histograms** (default 469→470 / 11→10 / match 225→226; testflags 465→466 / 8→7 / 165→166) |
| YosysVerx conversion, OFFICIAL `uhdm-cmp`, both modes | CMP_EQUAL | **verified independently**: rc=0, 0 output lines, 0 `^LHS:` heads, both modes |
| `dump match` | byte-identical | **verified independently**: `uhdm-dump` bodies identical, 147,656 lines, both modes |
| ladder BEFORE | 1 rung, ours_objs 36,089 | **same**, and reproduces committed `r10ladder1repro/ladder_*_YosysVerx.txt` rung for rung (same L/R, same `#19575`) |
| ladder AFTER | 0 rungs, ours_objs 24,205 = golden | **same** |
| 10-arm `grid.sh` | table in GRID.txt | **re-ran every arm, identical verdicts** |
| `census.sh` | 1 dotted decl corpus-wide | **confirmed by an INDEPENDENT census** (`census2`: comment-stripping, multiline-tolerant scan of 14,612 files over BOTH corpus trees, including the uncompiled `*_synth.v` / `*_from_*.v`) — still exactly one: `\vexriscv.demo.GenFull` |
| named byte canaries | SVSwitch `4842211c4030`, InterfaceModPort `59a365f3ce2c`, YosysOldOr `d68e0796d62c`, BlackParrotComplex `e3e354129d5a`/`73a10e8217e5` | **all on their pins** for the verified binary |
| determinism | YosysVerx reproduces `6ccda350c24a` | **same hash across re-runs AND across both binaries** |

## 2. TWO REGRESSIONS FOUND AND FIXED (`vgrid.sh`, 33 arms)

The implementer's grid is 10 arms of plain modules answering one question
(bare vs full). This verification ran the WHOLE comparison — official
`uhdm-cmp` plus a span-stripped `uhdm-dump` diff — over the law's own domain:
dotted tops beside plain tops in both source orders, two dotted tops, dotted
tops with params / packages / structs / processes / hier refs / binds /
generates / **interface instances**, dotted programs and interfaces, plus
plain-only controls.

### R1 — SEGFAULT: a dotted top that instantiates an INTERFACE
`vgrid/v4_dotted_top_plus_iface.sv` (`module \a.b.C ...; plainif bus (); ...`)
— the pristine binary exits 0 and writes a database; the implementer's binary
**exits 139**. Cause: the new bare-top loop puts *every* def under the bare top
into `unrefDefs`, and the write-phase fallback there calls
`emitModuleDefPorts`, which reads `DefInfo::mod` — an INTERFACE def has none
(its shell lives in `ifaceDefMap`). Every other `unrefDefs` producer is
module/program-only for exactly this reason. **Fix:** skip
`useInterfacePath()` defs in that loop. The arm then comes out `CMP_EQUAL`
with a **0-line** span-stripped dump diff.

### R2 — dropped def-view LowConn actuals on a shared child
`vgrid/w1_shared_child.v` (dotted top FIRST in source order, plain top second,
both instantiating one `child`) — pristine is right, the implementer's binary
loses `port(a) → vpiLowConn ref_obj(work@child.a.a) → vpiActual
logic_net(work@child.a)` in `child`'s **def view** (one `uhdm-cmp` head,
`LHS: logic_net(work@child.a)` / `RHS: <null>`). Cause: `collectDefs` keeps ONE
representative instance per definition (first encounter, source order) and
`emitModuleDef` fills that representative's `DefInfo::nets` keyed by ITS body's
symbols, while the port phase runs from whichever instance the instance walk
reaches first. A bare top runs no walk, so the walk arrives from the OTHER top
with a DIFFERENT `InstanceBodySymbol` and every `netMap.find(internal)` in
`emitPorts` misses. **Fix:** collect BARE tops LAST, so an elaborated subtree
owns the representative. Order-dependence proven by arm: `x1` (plain top
first) was already fine; `y1`/`y2` prove "a second top fills the def" is
harmless when the first top elaborated. With no bare top the two collection
passes are exactly the original single loop, so the fix cannot move any other
row — and measurably does not.

Both fixes are gated on `bareTops` being non-empty, which the corpus census
shows happens on exactly one test (whose only top is the dotted one, so the
reorder is a 1-element no-op there): the verified binary reproduces the
implementer's converted `YosysVerx` database **byte-for-byte** (`6ccda350c24a`,
both modes) and moves nothing else.

### The three-way arm table (`CMP/span-stripped dump-diff lines`)

```
ARM                      PRISTINE      IMPLEMENTER   VERIFIED
v4_dotted_top_plus_iface NE/108        REJECT(139)   EQUAL/0     <== R1 crash
w1_shared_child          NE/187        NE/4          EQUAL/0     <== R2
v2_genoff_dotted         EQUAL/0       EQUAL/0       EQUAL/0
v3_bind_outside          NE/138        EQUAL/0       EQUAL/0
v5_dotted_uninst_only    NE/78         EQUAL/0       EQUAL/0
w2_two_dotted            NE/366        EQUAL/0       EQUAL/0
w7_deep / w8_gen         NE/311,230    EQUAL/0       EQUAL/0
w9_dotstart / w10_dotend NE/183        EQUAL/0       EQUAL/0
w12_bind / w14_dotchild  NE/138,183    EQUAL/0       EQUAL/0
w17_hierref / w18_macro  NE/238,183    EQUAL/0       EQUAL/0
w19_dotdot / w20_unrefdef NE/183       EQUAL/0       EQUAL/0
x1_plainfirst_shared     NE/183        EQUAL/0       EQUAL/0
x3_ownchildren           NE/183        EQUAL/0       EQUAL/0
w11_rich                 NE/303        EQUAL/2       EQUAL/2     residue, PRE-EXISTING
w13_pkg/w3/w4 (params)   NE/251,301,457 NE/88,93,40  NE/88,93,40 residue
w16_threetop             NE/187        EQUAL/4       EQUAL/4     residue, PRE-EXISTING
w5_iface (dotted iface)  NE/24         NE/24         NE/24       PRE-EXISTING
x2/x4/x5/y1/y2 (controls) EQUAL/0,4,4,0,0 unchanged   unchanged   x4/x5's 4 is PRE-EXISTING
v1_pkgonly               NOGOLD        NOGOLD        NOGOLD      SURELOG segfaults
w15_ifaceport            REJECT        REJECT        REJECT      not a valid slang top
```

A raw `uhdm-dump` verdict is useless on these arms: Surelog's COLUMN numbers on
any line carrying an escaped identifier are offset by the escaped name's
length, so every dotted arm reads `dump differ` on spans alone. `vgrid.sh`
therefore reports both raw and span-stripped, and `uhdm-cmp` stays the judge.

## 3. RANKED RESIDUES (all measured, none pass-induced)

1. **Def-view net/port typespec ranges FOLDED where golden keeps the
   operation** — a dotted top with param- or package-dependent net ranges
   (`w3_paramnet` 93 lines, `w13_pkg` 88, `w4_paramchild` 40; `uhdm-cmp`
   head: golden `operation(W-1)` vs our `constant 3`). Pristine is NE too, so
   the pass moved these rows from "whole top missing" to this residue.
   **The implementer's unshipped `tfContext` arm was re-measured here behind
   the same kind of switch: it is NOT inert** (w3 93→40, w13 88→73) and it does
   NOT close the gap (one head either way). Not shipping it was right; the
   production NOTE has been corrected to say so for the right reason.
   No corpus row witnesses this — the one dotted top has no param-dependent
   net range.
2. **Two def-view `logic_typespec`s six lines early in the arena on a
   multi-top design sharing a child** (`w16_threetop`, 4 lines) —
   **PRE-EXISTING**: the identical 4-line shape appears on `x4_twoplain_shared`
   and `x5_threetop_plain`, which contain NO dotted name, under the PRISTINE
   binary. `uhdm-cmp` EQUAL; dump-only.
3. **A `$unit`-scope `struct_typespec` in `design->Typespecs` missing
   `vpiParent: design`** (`w11_rich`, 2 lines) — **PRE-EXISTING**: identical on
   the pristine binary in the pre-`uhdmtopModules` region. `uhdm-cmp` EQUAL.
4. **A dotted-name INTERFACE declaration** (`w5_iface`, 24 lines, one head: an
   extra `ref_typespec` on the interface's def-view net) — identical on all
   three binaries. A dotted interface is not a design top, so the law does not
   reach it.
5. **Surelog itself segfaults on a dotted PACKAGE name** (`v1_pkgonly.sv`,
   `package \p.k.G;`) — no golden exists, so no row can move; all three of our
   binaries exit 0 on it. Out of scope, recorded so the next pass does not
   mistake it for our crash.

## 4. Gate-5 CORRECTION: the surelog byteverify has THREE movers, not two

`SELFCHECK=1 byteverify.sh` (verified-vs-pristine workdirs) reports
**3 / 953**: the two `YosysVerx` databases (`d25dce77fe22 → 6ccda350c24a`,
both modes) **and** `./default/Scoreboard-59431470/slang.uhdm`. Scoreboard is
**NONDETERMINISTIC**, not a pass effect, and this was proven rather than
assumed:

* serial re-runs of BOTH binaries on Scoreboard's own command line give the
  same hash (`f383a9b83ff3`) — the patch changes nothing;
* three IDENTICAL `--jobs 2` sweep runs of the SAME pristine binary produced
  `f383a9b83ff3`, `e550acc4399b`, `f383a9b83ff3`, and the original pristine
  sweep produced `6dcd81633525` — **three distinct states from one binary**.

This is the known macro-buffer `SourceLocation` nondeterminism. Any pass that
cites "N movers" on the surelog corpus must exclude Scoreboard by re-running
it, exactly as here; the implementer's "2 movers, every mover named" was true
of their run only by luck of the draw.

## 5. Reproduce

```sh
./vgrid.sh <slang-uhdm> <tag>          # 33-arm adversarial grid (this file's table)
./grid.sh  /tmp/mygrid                 # the implementer's 10 bare/full arms
./census.sh                            # corpus census
CTLADDER=<ctladder> rowladders.sh <workdir> <out> default:YosysVerx testflags:YosysVerx
```
