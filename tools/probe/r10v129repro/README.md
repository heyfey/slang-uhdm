# r10v129 — ADVERSARIAL VERIFICATION of r10uvm129 § `declArrayElemVarSignedIsAtomKeyword129`

**VERDICT: ACCEPT-WITH-FIX.** The production change is correct, minimal and
gated; every headline number reproduced on binaries this verifier built
itself. The fix is to the PROBE surface only: `pred129.sh` could not
reproduce its own committed evidence (§4 below), and three statements in
`r10uvm129repro/README.md` overreach (§5). Production is byte-unchanged from
the implementer's patch.

**MEASUREMENT ONLY.** The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp` and
`scripts/verify_golden.py`. slang was NOT patched. `results/*.csv` were READ
ONLY. Nothing promoted, NO corpus row converted. **LHS is always golden.**

| | |
|---|---|
| BASE | `aef5007` |
| verifier worktrees | one patched, one pristine, both fresh at `aef5007` |
| pristine md5 | `e36cb36103acbc3c2e44797ddc81a745` — **matches the implementer's** |
| patched md5 | `991fceb46f6776bfbb7627c52cd3ccd4` — **matches the implementer's** |
| both frozen `chmod 555` before any sweep; `SLANG_UHDM` exported per binary; every `cmds.txt` audited by binary PATH | 1523 `slang:` lines surelog + 1458 uhdm2rtlil, **all** the frozen binary, 0 others, on each of the four sweeps |

## 1. GATES — reproduced independently

| gate | implementer | verifier |
|---|---|---|
| goldens (patched) | 23 PASS / 0 FAIL | **23 PASS / 0 FAIL** |
| `/bin/false` negative control | 23 FAIL | **23 FAIL, 0 PASS** |
| uhdm2rtlil testflags / default | 679 / 50 / 2 each | **679 / 50 / 2 each** |
| surelog `--mode both` histogram | 937 EQ, 19 NE, 567 REJ, 48 SLFAIL, 10 DEF, 3 NODB, 2 UNTR, 1 TO, 1 NOUHDM | **identical, and identical to this verifier's own pristine sweep** |
| ct8rows vs committed baselines, and vs own pristine, all five | PASS | **PASS ×5** |
| byte movers uhdm2rtlil | 0 / 1358, PATH_SETS_IDENTICAL | **0 / 1358, PATH_SETS_IDENTICAL** |
| byte movers surelog | 2 / 956 | **3 / 956** — the two predicted BuildUVMPkg rows **with the same hashes** (`patched=0db7826898e5 pristine=3d969c9fcc06`) **plus Scoreboard/default**, which is the documented COIN: in-order 92 lines, **ORDER-BLIND 0** |
| mover attribution | one dump line each, `< |vpiSigned:1` | **identical, in order AND order-blind** |
| canaries | ok=52 / ok=8, changed=0 | **ok=52 / ok=8, changed=0** |
| ctcan2 ×2, canaudit | PASS, `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **PASS ×2, `audited=29 UNCOVERED=0 FENCE-BREACH=0`** |
| protected DBs | all SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | **all SAME, both pins match** |
| heads | BuildUVMPkg 54→60 (new object), all others byte-identical | **reproduced; every one of the 11 pristine AND 11 patched head logs is BYTE-IDENTICAL to the committed `head_pris_*` / `head_pat_*` evidence, Scoreboard/default included** |
| new head (R0) | `sys_func_call ($bits)` over `hier_path abstractions.size`, `82730:10-82731:48` | **confirmed verbatim** |

## 2. THE BOUNDARY — reproduced bit for bit, independently

This verifier wrote its own wide gate (`vbound2.sh`: both frozen binaries,
both views, file list on fd 3, children `</dev/null`, scratch keyed on the
RELATIVE path, `PROCESSED` asserted, the `uhdm-dump` header line dropped
before diffing) and ran it over the whole of `tools/probe`:

```
LISTED=3857  PROCESSED=3857  MOVED=82 arm-views (41 unique arms)  NO_OUTPUT_PAIRS=294
moved dump lines 1436 — every one of them |vpiSigned:N
removals 1427   additions 9
```

Every number, and the 41-arm SET itself, is identical to
`BOUNDARY.r10uvm129.txt`. The 9 additions are confined to
`r10uvm129repro/g129_c_dims.sv` and `r10uvm80repro/v2_kinds80.sv`, and grid 4
below proves the direction independently: for `int mxInt129 [43][]` golden
carries `sgn=1`, pristine gave `0`, patched gives `1` — **TO-GOLDEN**.

**Must-stay controls.** A separate boundary over `r10uvm112repro`,
`r10v112repro`, `r10uvm114repro`, `r10uvm123repro`, `r10v123repro`,
`r10uvm126repro`, `r10v126repro` (68 files, both views): the uvm112 / uvm114 /
uvm123 arms are **byte-identical**, 0 moved lines. The only movers are the
uvm126 family, and they move by exactly the counts the implementer published
(`g126_a_kinds` 1/4, `v126_a_sign` 6/24, `v126_b_forms` 1/4, `v126_e_edge`
2/8), all `|vpiSigned:N`. Re-measured against their own Surelog goldens:
`v126_a_sign` LAW-FIXED 6 (`k_sgn126v` `k_sgnv126v` `q_sgn126v` `q_sgnv126v`
`r_sgn126v` `t_sgn126v`, all G=0 P=1 Q=0), `g126_a_kinds` LAW-FIXED 1
(`tally126`, a `cnt126_t` typedef of `int`). LAW-BROKE 0.

## 3. FIVE INDEPENDENT ADVERSARIAL GRIDS — the law did not break

Built here, not inherited: Surelog `-parse -nobuiltin -nocache -sv` golden,
both frozen binaries, both views, `cen129` census, `vscore129.py` joining on
the array_var NAME and scoring the LAW FIELD alone with a COLLATERAL counter
on every other field.

| grid | what it attacks | cells/view | LAW-FIXED | LAW-BROKE | LAW-STILL-WRONG | COLLATERAL | drift |
|---|---|---|---|---|---|---|---|
| `vg129_1_imports.sv` | **wildcard import**, **explicit import**, `pkg::name` qualification, **`$unit` typedefs**, typedef-of-typedef, packed / packed-signed / unpacked struct typedefs, class handle, string, 1–3 instances of one typedef | 37 | **22** | **0** | **0** | **0** | 0 |
| `vg129_2_homes.sv` | 9 homes: package function, package task, package variable, class property, in-body class task, **out-of-body class method**, module variable, module task, `initial` named begin | 24 (+4 ONLY-GOLDEN) | **8** | **0** | **0** | **0** | 0 |
| `vg129_3_dims.sv` | fixed 1-D, fixed 2-D, dynamic, queue, associative (`string` / `int` / class / typedef keys), each with a named face and an `int` control, in a task and in a class | 36 | **16** | **0** | **0** | **0** | 0 |
| `vg129_4_break.sv` | the GUARD interactions: **type-parameter** element types (the `ref_var` path) in all four dimension kinds, class-nested typedef named bare and `Class::td`, nested begin, `for`-loop block, `fork` block, `const`, `static`, mixed `[N][]`, 2-D of a named enum | 26 | **11** | **0** | **0** | **0** | 0 |
| `vg129_5_implicit.sv` | the `ImplicitType` carve-out: `var int`, `var signed [3:0]`, `var logic [7:0]`, `var byte`, bare `var` | — | — | — | — | **0** | 0 |
| **total** | | **123 joined + 4 ONLY-GOLDEN** | **57** | **0** | **0** | **0** | **0** |

Both views are identical cell for cell.

**The positive controls fire.** 25 golden-signed cells (`int`, `integer`,
`byte`, `shortint`, `longint` locals across every home and every dimension
kind, including the multi-declarator pair `iPos1129, iPos2129` and a
`const int`) are `sgn=1` in golden and stay `sgn=1`. `int unsigned` and
`byte unsigned` stay `0`. A rule that merely stopped stamping would have
broken all 25.

**The `ref_var` guard survives the switch from "or-in" to "write".** The
patched sites now write `VpiSigned(false)` where the old code left the
factory's value; grid 4 shows the type-parameter cells (`tpLoc129`,
`tpQue129`, `tpDyn129`, `tpAsc129`) are `ref_var sgn=0` in golden AND in both
binaries — nothing was cleared that golden wanted.

**The `ImplicitType` carve-out is honest.** Surelog emits **no array_var at
all** for any `var`-keyword local (all five cells `G=NONE`), so there is no
golden to move toward, and the two databases are byte-identical (1457 cmp
lines pristine and patched).

## 4. THE FIX — `pred129.sh` could not reproduce its own evidence

`score129.py`'s summary line spells the law counter **`LAW-WRONG=<n>`** and
carries no `LAW=` label at all. `pred129.sh` extracted it with
`grep -o 'LAW=[0-9]*'` and `grep -o 'LAW+TSSPAN=[0-9]*'` — neither can ever
match. As committed the script printed `PREDICTED_MOVERS=0` on **every**
input: the pre-patch `PREDICT law=1 … PREDICTED_MOVERS=2` block was not
reproducible from it, and the post-patch "`PREDICTED_MOVERS=0` — not one law
cell left" line was **vacuous**.

Fixed here (`pred129.sh`, two lines plus a guard): read the real label, and
print `PARSED=<n>`, the number of score lines actually seen, so a future label
rename surfaces as `PARSED < SCANNED` instead of as a silent zero. With the
fix the committed script reproduces the claim on this verifier's own workdirs:

```
pristine:  SCANNED=2314 PARSED=2314 PREDICTED_MOVERS=2 WITH_TSSPAN=13 NO_GOLDEN=0
             PREDICT law=1 tsspan=70 default/BuildUVMPkg-bf853d43
             PREDICT law=1 tsspan=70 testflags/BuildUVMPkg-bf853d43
patched:   SCANNED=2314 PARSED=2314 PREDICTED_MOVERS=0 WITH_TSSPAN=13 NO_GOLDEN=0
```

so the substance of the claim — two law cells in 2314 databases before, none
after, both named a priori — **holds**. (`tsspan` per row reads 70 here where
the pass wrote 66; that is a residue tally, not a law cell, and `WITH_TSSPAN`
matches at 13.)

## 5. THREE CORRECTIONS TO THE PASS'S PROSE (no code implication)

1. **`var->VpiSigned(isSigned)` occurs EIGHT times in `compileVariable`, not
   seven**, at `~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:418 454
   464 474 484 494 504 514` — the pass's table is two lines low throughout and
   omits `:418`. That eighth site is inside the NAMED-TYPE arm: an unresolved
   name with `implicitInt=true` mints an `int_var` and stamps the flag. It is
   unreachable for a declarator array — the block-item caller
   `CompileStmt.cpp:1191` passes the default `false`
   (`include/Surelog/DesignCompile/CompileHelper.h:278`) — so the law and the
   code stand; only "and NOWHERE ELSE" is too strong.

2. **The law is missing its SCOPE qualifier.** As written it predicts that
   `int a[N]` carries `vpiSigned` wherever it appears. Golden stamps it only
   in a SUBROUTINE / BLOCK-ITEM declaration. Measured against Surelog goldens
   in `vg129_2_homes.sv`: module variable `int modInt129[47]` `sgn=0`, class
   property `int propInt129[27]` `sgn=0`, `integer modIntg129[49]` `sgn=0`,
   `longint propLong129[29]` `sgn=0` — against function local
   `int fnInt129[15]` `sgn=1` and class-task local `int itInt129[33]` `sgn=1`
   in the same file. That is precisely why residue R2 (`int i_int[i_idx]` at
   module scope in `r10uvm43repro/t60a/dut.sv`, 15 cells, re-measured here as
   LAW-STILL-WRONG and byte-unchanged) is NOT reachable from this pass's four
   block-item sites, and it means R2 is not "the same law at another site" but
   a SECOND rule: at module / class / package scope the flag is never written
   at all.

3. §1a's refutation is CORRECT and independently reproduced. `cen129`'s
   id-free `TSOBJ` family on the BuildUVMPkg pair gives, on this verifier's
   own databases:
   `GOLDEN enum_typespec|uvm_pkg::uvm_check_e 62383:35-62383:46 nrefs=16` and
   `79053:35-79053:46 nrefs=5`; `OURS 60837:4-60840:18 nrefs=16` and
   `60837:4-60840:18 nrefs=5`. Two objects each side, same referrer counts —
   the binding is already golden's and the span is dump-only
   (`enum_typespec.cpp`'s generated `Compare` reads no file/line/column;
   `variables.cpp:251` DOES read `VpiSigned`).

## 6. RANKED RESIDUES (verifier's ordering)

1. **R0 as the pass names it** — the `$bits(abstractions.size)` head, shared
   with SimpleUVM ×2 and Scoreboard/default (three row-modes, one decode).
   Confirmed byte-for-byte as the new BuildUVMPkg ×2 head.
2. **The element TYPESPEC in the fixed-size tf/begin arm** (uvm126 residue 1).
   Visible in every grid here: golden binds the shared NAMED typespec
   (`enum_typespec|vpk129::pEnumInt129_e`), ours binds an anonymous
   `bit_typespec` / `logic_typespec` / `int_typespec`. 6–9 cells per UVM DB.
   ONE site — `TaskFuncEmit.cpp`'s hand-rolled `elemTs` ladder. The queue /
   dynamic / associative arms already get it right, which makes it the
   cheapest cell-per-fix left in this family.
3. **Module / class-scope element `vpiSigned`** — the SECOND rule of §5.2, 15
   cells in `r10uvm43repro/t60a` alone, 0 corpus cells.
4. **The element VARIABLE CLASS at module scope and in the mixed `[N][]`
   shape** — golden `byte_var` where ours gives `int_var`
   (`modTdByte129`), golden `int_var`/`enum_var` where ours gives `logic_var`
   (`mxInt129`, `mxEnum129`).
5. **Package variables list no array_var at all in ours** (grid 2's four
   `hPkg*` cells are ONLY-GOLDEN in both binaries) — an object-count gap, not
   a field gap.
6. **The shared named typespec's SPAN** — dump-only, 13 of 2314 databases.

## 7. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `vg129_1_imports.sv` … `vg129_5_implicit.sv` | the five adversarial grids of §3 |
| `vscore129.py` | the verifier's own scorer: joins golden / pristine / patched `cen129` censuses on the array_var NAME, scores the LAW FIELD, counts COLLATERAL on every other field and OBJSET-DRIFT on the object set |
| `vbound.sh` | the must-stay-control boundary of §2 (one root, both binaries, both views) |
| `vbound2.sh` | the same gate sharded over N workers, used for the 3857-file run |

Reproduce a grid with `r10uvm129repro/arm129.sh`:
`PRIS=<pristine> PATCHED=<patched> CEN129=<cen129> arm129.sh vg129_1_imports.sv <outdir>`,
then `vscore129.py <out>/g.cen <out>/o.cen <out>/q.cen TAG`.
