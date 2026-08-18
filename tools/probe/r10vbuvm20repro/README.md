# r10vbuvm20 — ADVERSARIAL VERIFICATION of r10buvm20 (§ `pkgClassOobRetNameBareClone20`)

**VERDICT: ACCEPT-WITH-FIX.**  Every headline number of the implementer's pass
reproduced BIT-FOR-BIT from independently rebuilt binaries.  One
**pristine-right → patched-wrong** family was found on legal SV and FIXED here;
the fix is BYTE-INERT on both corpora (all nine mover databases keep the
patched md5s) and preserves every conversion.

**MEASUREMENT ONLY.**  The official `uhdm-cmp` and `scripts/verify_golden.py`
are the only judges.  `results/*.csv` were READ ONLY; nothing was promoted;
slang was not patched.  **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `de79702` |
| worktrees | `/tmp/wt_vbuvm20` (patched), `/tmp/wt_vbuvm20pris` (pristine), `/tmp/wt_vbuvm20fix` (patched + verifier fix) |
| pristine binary | md5 `7aa2538c15f50452f39416bd6e2036e3` — **matches the implementer's** |
| patched binary | md5 `ac97b47aa254cc61c5598ec872194560` — **matches the implementer's** |
| FIXED binary | md5 `7e151433e432bf8c97ec7c8419ad52c4` |
| frozen at | `/tmp/vbuvm20_bin/{pris,pat,fix}.bin`, `chmod 555`, before any sweep |
| deliverable | `/tmp/r10buvm20.verified.patch` |

## 1. REPRODUCTION — every headline number, bit for bit

| claim | implementer | verifier |
|---|---|---|
| pristine binary md5 | `7aa2538c15f5…` | **same** |
| patched binary md5 | `ac97b47aa254…` | **same** |
| `BuildUVMPkg` cmp lines `2>&1`, both modes | 152 → 29 | **152 → 29** |
| stderr-only lines | 76 → 15 | **76 → 15** |
| cmp md5 `2>&1` pristine / patched | `23df339e1b17…` / `6e1067f47e20…` | **`23df339e1b177269ecf960e2ba8097e9` / `6e1067f47e20fd6cf7dd7509fb3eb99e`** |
| heads | 1 / 1 | **1 / 1** |
| other ten row logs byte-identical | yes | **yes** (`cmp -s` on the raw logs) |
| surelog rows vs committed baseline | PASS 0 differing / 1588 | **PASS**, status AND dump, patched AND pristine |
| u2r tf vs committed | PASS, 679/50/2 | **PASS, 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** |
| u2r default pris vs pat | PASS | **PASS** |
| goldens | 23/0, `/bin/false` → 23 FAIL | **23/0 patched, 23/0 pristine, 23 FAIL negative control** |
| byteverify surelog | `MOVERS 9 / 956` | **9 / 956, the exact predicted set** |
| byteverify u2r | `MOVERS 0 / 1358` | **0 / 1358** |
| a-priori prediction (GOLDEN dbs only) | 22 tests / 42 pairs surelog, 0 u2r | **42 `PREDICT` lines over 22 tests; u2r 0** |
| ∩ produces-a-database | the 9 movers | **exactly those 9, zero unpredicted** |
| corpus census `BuildUVMPkg` | same 8949, CONVERTED 2, OVER-FIRE 0, MSW 2, residue 3850 | **identical, every number** |
| whole-dump diff `BuildUVMPkg` | 20 removed / 173 added, all in the two named cells | **20 / 173, 9 hunks, two contiguous regions = the `unpack_field` / `unpack_field_int` body-local return typespec subtrees** |
| canaries / ctcan2 / canaudit | 52/0, 8/0, PASS, `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **same** |
| protected DBs | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, three byte-identical | **same** |
| R0's decode (`ref_obj::Actual_group` at a `bit_select` index) | golden binds the formal's `io_decl`, ours NULL | **CONFIRMED** by `r0.cpp`: golden `ref_obj @30001:22 parent=bit_select actual=io_decl(severity)`, ours `actual=NULL` |
| fence check on the patch | 0 hits × 4 names | **0** |
| every `cmds.txt` names exactly one binary | yes | **3035 files per sweep, one path each** |

`/tmp/vbuvm20_wd_{pris,pat,fix}`, sweeps driven by `sweep.sh` with
`SLANG_UHDM` exported per binary and every `cmds.txt` audited BY PATH.

## 2. THE FINDING — pristine-right → patched-wrong, and the FIX

The patch's `sameScope0` reach-through fires on the **class scope chain alone**
and never asks how the type was **WRITTEN**.  Golden distinguishes the two
spellings; the implementer's own Surelog decode says so
(`compileTypespec` clones and bare-names only a reference that resolves
THROUGH a `TypeDef` by its plain name).  Arm `v8_qualfixed.sv`, cells
`vp8::C8::q8` / `q16` / `q1`, site RETLOCAL, view ELABPKG:

```
G  logic_typespec(vp8::l8_t)[noalias]                  rg=1[C7:C0] sg=1 inst=package(vp8)
O  logic_typespec(vp8::l8_t)[noalias]                  rg=1[C7:C0] sg=1 inst=package(vp8)   <- FIELD-FOR-FIELD GOLDEN
P  logic_typespec(l8_t)[alias->logic_typespec(vp8::l8_t)] rg=1[C7:C0] sg=1 inst=package(vp8) <- WRONG on VpiName AND Typedef_alias
```

`typespec::Compare` reads `VpiName` FIRST, so the patch moves a cell that was
already perfect off the first field it is judged on.  The fixed-range typedef
is what makes this a clean regression rather than a residue shuffle: with a
parameter-dependent bound (`v2_sites.sv` `oob_q`) the fold axis masks it.

**THE FIX** (`src/ModuleEmit.cpp`, 10 code lines + comment): gate the NEW class
reach-through on `writtenBare20` — the return type must be written as a plain
`IdentifierName`, not a `ScopedName` — using `returnTypeSyntax(sub)` and
exactly the `NamedTypeSyntax → IdentifierName` test
§ `pkgParamBareTdNamedClone18` already applies to parameters
(`writtenBare18`, `ParamEmit.cpp`).  When the type is written qualified the
loop does not run, `fsc20` stays at the class, `sameScope0` is false and the
pristine (correct) qualified-share path is taken.  The pre-existing
free-function arm is NOT touched.

Field-level scoring over 10 arms × 2 views (`score.py`,
TO-GOLDEN / AWAY / STILL per Compare-visible slot):

| | patched | FIXED |
|---|---|---|
| TO-GOLDEN name / alias / rg | 21 / 21 / 18 | **21 / 21 / 17** |
| **AWAY name / alias** | **10 / 6** | **4 / 0** |

and on the corpus the fix is **byte-inert**: all nine mover databases keep the
patched md5s (`9414d08e1569`, `cb9fb37818d9`, `64c57e4df7f6`, …), because
`uvm_pkg` never writes its own typedefs package-qualified inside itself.

## 3. THE ADVERSARIAL GRID (10 arms, `cmparm3.sh` + `grid3.sh` + `join.py`)

Official `uhdm-cmp` per arm, **BOTH views** (default and `-elabuhdm` /
`--elabuhdm`), three binaries:

| arm | axis | pris | pat | fix |
|---|---|---|---|---|
| `v1_kinds` | logic/bit/byte/int/shortint/longint/integer/time/real/string/enum/struct/union/typedef-of-typedef/fixed-range/scalar/signed × class OOB return | 42/1 | 42/1 | 42/1 |
| `v2_sites` | return, formal in/out/inout/ref/default-valued, local, STATIC local, property, in-body vs OOB, static, virtual, extern, task vs function, void | 13/1 | 13/1 | 13/1 |
| `v3_homes` | class in package / module / interface / program / `$unit` / GENERATE block, nested class, parameterized class, virtual override | **152/1** | **18/1** | **18/1** |
| `v4_crosspkg` | typedef from ANOTHER package: wildcard import, explicit import, qualified, re-typedef | 52/1 | 52/1 | 52/1 |
| `v5_prefix` | package-name PREFIX traps `w`/`work@`, `a`/`ab`, `chain1`/`chain12` | 126/1 | 126/1 | 126/1 |
| `v6_noimport` | package class with NO importer, NO instance | 33/1 | 33/1 | 33/1 |
| `v7_multiinst` | 3 module instances importing the package class | **152/1** | **0/0 EQUAL** | **0/0 EQUAL** |
| `v8_qualfixed` | package-QUALIFIED written return, FIXED range (the finding) | 126/1 | 126/1 | 126/1 |
| `v9_tdoftd` | typedef-of-typedef chains, fixed range | 52/1 | 52/1 | 52/1 |
| `v10_min_qual` | minimal isolation of the qualified spelling | 126/1 | 126/1 | 126/1 |

`v7_multiinst` **CONVERTS to fully EQUAL** — the law's positive control, on the
official judge.  `v3_homes` 152 → 18 (the residual head is an unrelated
parameterized-class `int_typespec` `vpiSigned` family, identical in all three).
**No arm moves from EQUAL to NOT-EQUAL in either view, on any binary.**

Census verdicts (`join.py`, view-general, multiset join, key
view|owner|site with the location OUT of the key):
**OVER-FIRE = 0 on all 14 arm × view combinations** of the implementer's
original arm set, and on all 20 with mine.

## 4. THE BOUNDARY GATE (`bound.sh` + `bworker.sh`)

Recursive over a **COPY** of `tools/probe` (`/tmp/vbuvm20_probecopy`, so no
arm in the real tree is touched), **subdirectories included by construction**
(`find`), arm list on **fd 3**, every child `</dev/null`, **rc recorded per
cell**, PROCESSED asserted, banner normalised, **THREE binaries × BOTH views**:

```
PROCESSED=2919  LISTED=2919   ASYM=0   ERR=0   rc cells recorded=17514
DIFFERING CELLS: 26 — every one of them under tools/probe/r10buvm20repro/
   g20.sv (the pass's own grid arm, its positive control)
   v1..v10 (THIS directory's arms)
```

**Zero movement across all 2909 pre-existing arms** — every bind-window law in
the tree (`§ classArgBind12`, `§ retNameRecvCollapseArgsBindLikeBody15`,
`§ collArgNamedBlkLocalNoBind15`, `§ controlBodyNoBind28`,
`§ blkLocalSameCtrlDepthArgBinds57/64`, `§ pkgVarBindsOnlyThroughInstance88`,
`§ formalDefaultBindsLikeBody13`, `§ classInBodyRecvCallArgNoBind52`,
`§ superNewFormalBinds28`, `§ newArrayArgNoBind16`,
`§ foreachElabLoopVarAnyKindBinds17`, `§ pkgParamBareTdNamedClone18` incl.
`grid18`/`b1`-`b4`, `§ foreachArraySelfSelectAssignDropsTs19`, uvm82-95,
sd8-12, buvm3-19) is proved untouched in BOTH views, not argued.
`v10_min_qual` and `v8_qualfixed`(elab) differ pris-vs-**pat** and NOT
pris-vs-**fix** — the fix's own positive control.

## 5. RANKED RESIDUES

1. **R0 (the new head, unchanged by the fix)** — `io_decl (severity)` id 129936
   / `RHS: <null>`, `BuildUVMPkg` both modes, 29 lines, md5 `6e1067f47e20`.
   Independently confirmed with `r0.cpp`: golden's `ref_obj` at
   `uvm_pkg.sv:30001:22`, `VpiParent` a **`bit_select`** (the index of
   `m_severity_count[severity]++`), binds the formal's `io_decl` as
   `Actual_group`; **ours is NULL**.  A bind-window law at the bit-select INDEX
   position.  Next head.
2. **R1 — the fold half of the qualified spelling.**  With the fix, a
   package-QUALIFIED written return keeps golden's name and share but its
   packed bound stays **symbolic** where golden folds (`v2_sites` `oob_q`:
   `rg=1[Soperation:C0]` vs golden `rg=1[C4095:C0]`).  Cost of the fix: one
   `TO-GOLDEN:rg` (18 → 17).  Pre-existing on the free-function site.  The
   right shape is a `writtenQualified → share + fold` arm, one pass of its own.
3. **R2 — typedef-of-typedef** (`typedef base_t chain_t`).  Golden takes the
   TypeDef arm: the **listing object under its QUALIFIED name**, aliased to the
   BASE typedef, folded (`logic_typespec(vp9::chain_t)[alias->logic_typespec(base_t)]
   rg=1[C7:C0]`).  We emit no ranges at all here (`rg=-`), in BOTH binaries and
   at BOTH the RET and RETLOCAL sites, so the cell is unequal either way and no
   equality can be lost — but the patch does move `VpiName` off golden
   (4 remaining `AWAY:name`).  Left unfixed deliberately: closing it means
   modelling the whole typedef-of-typedef family (RET site included, free
   functions included), which is outside this pass's window.
4. **R3 — the imported-package bare spelling is a MISSED conversion.**
   `v4_crosspkg` `vpb::CB::b_ret_bare` / `vpc::CC::c_ret_bare`: golden gives
   the bare clone + alias + folded for a typedef imported from ANOTHER package
   and written bare; the law's "same package" test refuses.  Golden's real rule
   is the **written spelling**, not the home.  0 cells on the corpus today.
5. **R4 — we mint TWO body-local return variables per OOB method** where golden
   mints one (the DEFPKG twin, `G=None`).  Identity and count are not fields
   `Compare` reads and `m_visited` is keyed on the LHS; both copies now carry
   the same shape.
6. **R5 — the class-method `vpiInstance` family**, 2780 `io_decl` + 949 `RET`
   cells on `BuildUVMPkg` where golden carries `vpiInstance -> package uvm_pkg`
   and we carry none.  Identical in all three binaries; masked.
7. **Documentation nit** — the implementer's README says the production surface
   is "57 added lines, 48 of them comment"; the patch is **49 added lines, 37
   comment, 12 code** (the report says 49/40).  Numbers only.

## 6. THE INSTRUMENTS

| file | what it is |
|---|---|
| `v1`…`v10*.sv` | the adversarial grid of § 3 |
| `cmparm.sh` / `cmparm3.sh` | official `uhdm-cmp` per arm, BOTH views, 2 or 3 binaries, rc recorded |
| `grid.sh` / `grid3.sh` | golden + N binaries × BOTH views into `r10buvm20cen` censuses |
| `join.py` | view-general three-way multiset join; `LOCKEY=1` keeps the location in the key (the implementer's keying), default drops it so a prototype-vs-definition location difference cannot manufacture residues |
| `score.py` | per-slot **TO-GOLDEN / AWAY / STILL** scoring on the Compare-visible payload (typespec kind, `VpiName`, `Typedef_alias`, packed-bound encoding, `VpiSigned`, `vpiInstance`) — the instrument that found the regression |
| `bound.sh` / `bworker.sh` | the boundary gate of § 4 (COPY of `tools/probe`, fd-3 list, `</dev/null` children, PROCESSED asserted, rc per cell, N binaries × BOTH views) |
| `sweep.sh` | both corpora both modes with ONE named binary into a workdir this pass owns |
| `r0.cpp` | the R0 decode probe (`ref_obj` → `Actual_group` at line 30001) |
