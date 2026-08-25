# r10v126 — ADVERSARIAL VERIFICATION of r10uvm126 (§ `declArrayElemTsIsWrittenKeyword126`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's report
reproduced BIT FOR BIT from independently built binaries. One defect was found
by breaking the law — a `time signed` element typespec moved to the right class
and the WRONG `VpiSigned`, contradicting the pass's own decoded Surelog table —
and is fixed here in the pass's own helper, one arm, corpus-neutral. Ship
`/tmp/r10uvm126.verified.patch`.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py` are the only
judges. slang was **NOT** patched. `results/*.csv` were **READ ONLY**. **NO
CORPUS ROW WAS CONVERTED.** **LHS is ALWAYS golden (Surelog); RHS is ALWAYS
ours** in every table below and in every script here.

| | |
|---|---|
| BASE | `0a5551e` |
| verifier worktrees | `/tmp/wt_v126pris` (pristine) and `/tmp/wt_v126` (patched, then patched+fix) |
| pristine binary | `9eeb7f38678c006f7d2bb3ac4d9cfd84` — **the implementer's stated pristine md5, reproduced by an independent build** |
| patched AS SHIPPED | `b8587364c34513da6006b77b8ee0cb7e` — **the implementer's stated patched md5, reproduced exactly** |
| patched + verifier fix | `d5b7813a2a6f053d14751d77e7949945` |
| all three | frozen `chmod 555` before any sweep; every `cmds.txt` audited by BINARY PATH |

---

## 1. WHAT REPRODUCED

Everything. Independently built binaries, independently driven sweeps,
independently written census and predictor.

| the implementer claimed | I measured | |
|---|---|---|
| pristine md5 `9eeb7f38…`, patched md5 `b8587364…` | identical from my own `cmake -j 2` builds | ✔ |
| head 12 lines / 1 head on SimpleUVM ×2, Scoreboard-default, BuildUVMPkg ×2 | 12 / 1 on all five | ✔ |
| the head is the unparented, unnamed `string_typespec` vs `logic_typespec` pair at `68:7-68:13` | byte-for-byte that, `id:158916` vs `id:84364` | ✔ |
| SimpleUVM ×2 + Scoreboard-def **12 → 124**, BuildUVMPkg ×2 **12 → 54** | exactly | ✔ |
| SeqDriver 28, MiniAmiq 28, Earlgrey 240/268 head logs BYTE-IDENTICAL | `cmp -s` says identical on all six | ✔ |
| Rggen/default CMP_EQUAL | 0 cmp lines, rc=0 | ✔ |
| u2r 679 / 50 / 2, both modes, 0 differing rows | exactly, on all three binaries | ✔ |
| surelog histograms unchanged, **0 differing rows over 1588**, no conversion | exactly, on all three binaries | ✔ |
| goldens 23/0 and `/bin/false` 0/23 | 23/0 pristine, shipped AND fixed; 0/23 negative control | ✔ |
| byte movers **9 / 956** surelog, **0 / 1358** u2r | exactly those 9, same hashes | ✔ |
| the 9 movers PREDICTED BY NAME from pristine databases | my own `predv126.sh`, which never opens a patched database, names the same 9 (SCANNED 956, NO_GOLDEN 0) and 0 of 1358 | ✔ |
| 6 dump lines each, 54 total, all `logic_typespec` → `string_typespec` at the same span | exactly, ORDER-BLIND (so Scoreboard/default's coin is attributed too) | ✔ |
| canaries 52/0 + 8/0, ctcan2 PASS ×2, canaudit 29 / 0 / 0 | exactly, on the fixed binary's sweep as well | ✔ |
| SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, three protected DBs SAME | exactly | ✔ |
| R0's two next heads | SimpleUVM's new head IS `operation` vpiOpType 15 at `1978:21-1978:76`; BuildUVMPkg's IS the `enum_var` `…do_block::field_check_restore` at `79885:25-79885:44` | ✔ |

The decoded Surelog model is correct as written:
`CompileHelper::compileBuiltinTypespec` at
`~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:1126-1231` is the closed
switch the pass says it is, `paString_type` → `string_typespec` at `:1220`,
`default:` → `logic_typespec`. Read it line by line and confirmed every row of
the pass's table, including the two `populateCoreMembers` span conventions
(`isSigned ? sign : type` for logic/bit, `isSigned ? type : sign` for the
integer atoms) — spans are not read by any generated `Compare`, so they cost
nothing either way.

I also confirmed the judge really reads what the law claims: `typespec::Compare`
reads `VpiName` / `Typedef_alias` / `Instance`; `array_typespec::Compare` reads
`Elem_typespec`; `string_typespec` / `event_typespec` / `chandle_typespec`
compare on the base class alone; and **`time_typespec::Compare` READS
`VpiSigned`** — which is finding V-1.

---

## 2. FINDING V-1 (FIXED HERE) — `time signed x[N]` reached the right class with the wrong `VpiSigned`

**How it was found.** r10uvm126's four grids carry **not one signing variant**,
and its census `cen126.cpp` **prints no `VpiSigned`** even though its own header
comment says it does. So the pass could not have seen this. `v126_a_sign.sv`
writes every integer-atom keyword × {bare, `signed`, `unsigned`}, and
`cenv126.cpp` adds the one missing field.

**Surelog, in the file the pass itself cites.** Every integer-atom row of
`compileBuiltinTypespec` calls `var->VpiSigned(isSigned)` — except one:

```cpp
    case VObjectType::paIntegerAtomType_Time: {          // CompileType.cpp:1188-1192
      time_typespec* var = s.MakeTime_typespec();
      fC->populateCoreMembers(type, type, var);          // <- no VpiSigned call at all
      result = var;
      break;
    }
```

The pass's own README states this (`paIntegerAtomType_Time … **no VpiSigned at
all**`) and then its code does the opposite:
`case TimeType: { auto* t = s.MakeTime_typespec(); t->VpiSigned(isSigned); … }`.

**The measurement**, `v126_a_sign.sv` cell `t_sgn126v` (`time signed t_sgn126v [3];`):

| | element typespec |
|---|---|
| golden | `time_typespec` `sgn=0` |
| pristine | `int_typespec` `sgn=1` (wrong class AND wrong field) |
| patched **as shipped** | `time_typespec` `sgn=1` — **MOVED-WRONG**: right class, wrong field, still not golden |
| patched **+ this fix** | `time_typespec` `sgn=0` — **FIXED** |

Three distinct declarations across two arms and both views: **MOVED-WRONG 10
as shipped → 0 fixed.** Because `time_typespec::Compare` reads `VpiSigned`, a
`time signed` array local in any corpus would have been a real, judge-visible
mis-move; the corpus happens to contain none, which is why every corpus gate
stayed green either way and why only a grid could catch it.

**The fix** (`src/EmitHelpers.h`, inside the pass's own
`writtenKeywordElemTs126`, one arm):

```cpp
        case syntax::SyntaxKind::TimeType:
            // § declArrayElemTsIsWrittenKeyword126v — the `time` row is the ONE
            // arm of Surelog's switch that never touches VpiSigned …
            return s.MakeTime_typespec();
```

**It is corpus-neutral, and that is measured, not assumed:**
`byteverify.sh` between the shipped sweep and the fixed sweep reports
**MOVERS 0 / 956** surelog and the fixed binary's mover set against pristine is
the SAME 9 databases with the SAME md5s. `ct8rows` shipped-vs-fixed = 0
differing rows. The head table is identical. Nothing else in the patch changed.

---

## 3. THE ARMS THAT BROKE THE LAW (and the ones that could not)

`ARMS.r10v126.txt` indexes all six. They cover, beyond r10uvm126's grids:

* **signing** — every atom × {bare, signed, unsigned}, plus `bit signed`,
  `bit signed [5:0]`, `logic signed`, `logic signed [6:0]`, `reg signed`;
* **declaration forms** — `var`, `automatic`, `static`, `const`, two declarators
  on one written type, a typedef of the ELEMENT and a typedef of the ARRAY;
* **homes** — an INTERFACE variable, an interface TASK local, a `$unit`
  function local, a for-loop block local, a fork/join_none block local, a
  constructor, a virtual method, a STATIC method, a class nested in a class, a
  task with a default-valued formal, a PROGRAM block, and a package class with
  three instantiations;
* **shapes** — queue / dynamic / associative (`[int]` AND `[string]`) / 2-D /
  3-D of `string`, the mixed `string [5][]`, and enum / packed-struct /
  unpacked-struct / class-handle elements;
* **controls that must not move** — `logic [9:0]`, `logic`, `bit [2:0]`, `bit`,
  `int`, `reg [1:0]` arrays: **SAME-OK in every arm, both views**;
* **illegal SV** — packed dimensions written on `int` / `byte` / `string` /
  `time`: both binaries reject symmetrically, rc=3, no segfault, both views.

Totals over the six arms, DEF + ELAB, pristine → patched+fix:

| | |
|---|---|
| SAME-OK | 63 |
| **FIXED** | **163** |
| **MOVED-WRONG** | **0** (10 as shipped — finding V-1) |
| **BROKE-AGREEING** | **0** |
| STILL-WRONG | 43 (residues, §5) |
| ONLY-GOLDEN / ONLY-OURS | 0 / 8 (shape differences identical in pristine and patched) |

r10uvm126's own four grids, re-scored under the fixed binary with MY census and
MY key: DEF FIXED 50, ELAB FIXED 107, **MOVED-WRONG 0, BROKE-AGREEING 0** in both
views. (My FIXED counts differ from the pass's 46 / 54 because my key carries the
owner's whole parent chain; the zeros are the assertions that matter.)

---

## 4. THE WIDE BOUNDARY

`bound126.sh` over a COPY of `tools/probe`, both binaries, both views, fd-3
list, children `</dev/null`, `PROCESSED` asserted, subdirectory arms included,
scratch keyed on the RELATIVE path:

```
LISTED=3804  FENCED_SKIPPED=0  PROCESSED=3804  MOVED=26  NO_OUTPUT_PAIRS=294
PROCESSED-ASSERT-OK            (no ASYMMETRIC_OUTPUT)
```

26 = **three earlier-pass arms** × 2 views + r10uvm126's four grids × 2 + this
directory's six arms × 2. The grids are the gate's built-in positive control.

Each earlier-pass arm re-measured against its OWN Surelog golden, both views:

| arm | verdict |
|---|---|
| `r10buvm8repro/v2_argts8.sv` (`string arr [2]`) | FIXED 1 (DEF) / 2 (ELAB), MOVED-WRONG 0, BROKE-AGREEING 0; the arm's own cmp line count UNCHANGED at 21748 |
| `r10sd12repro/grid12/h3.sv` (`byte` local) | FIXED 1 / 2, MOVED-WRONG 0, BROKE-AGREEING 0; cmp lines UNCHANGED at 3794; § `declArrayElemKindIsDeclKind12`'s own cells SAME-OK |
| `r10uvm20repro/t30/t.sv` (three `_f_str` cells) | FIXED 4 / 9, MOVED-WRONG 0, BROKE-AGREEING 0; cmp lines UNCHANGED at 14503; every queue / dynamic / associative cell SAME-OK |

Nothing else in 3804 arms moved a byte. In particular none of the boundary
arms named in the standing brief (uvm89's `hpTrailSelIdxDecompiled89` arms and
its boundary mover, uvm77-79, buvm14, uvm84/85, uvm82-91, buvm3-15, sd8-12)
moved at all.

---

## 5. RESIDUES, RANKED (none of them this law's, all measured)

**R-V1 — `signed` on a `logic` / `bit` / `reg` element typespec is dropped.**
Golden gives `logic_typespec` / `bit_typespec` `VpiSigned=1` for
`logic signed x[N]`, `logic signed [6:0] x[N]`, `bit signed x[N]`,
`bit signed [5:0] x[N]`, `reg signed x[N]`; ours gives `VpiSigned=0`. **5 cells
per arm, both views, pristine AND patched** — the fall-through arms this law
does not touch. `logic_typespec::Compare` and `bit_typespec::Compare` both read
`VpiSigned`, so these are judge-visible. Written-signing is exactly the gate
already decoded here (`isSigned ? sign : type` in Surelog's logic/bit rows), so
this is the cheapest remaining cell of the same family. **Ranked first.**

**R-V2 — `realtime x[N]` is `time_typespec` in golden, `logic_typespec` in
ours.** Measured in two homes (`v126_e_edge` cells `rt_arr126v`, `mrt126v`);
golden's element variable is a `logic_var` beside it. One line
(`case RealTimeType: return s.MakeTime_typespec();`) completes the pass's own
switch, and the corpus population is **zero** — the only `realtime` unpacked
array in either corpus (`Surelog/third_party/tests/Verilator/t_var_types.v:68`)
is a MODULE variable, which this arm never sees. Deliberately NOT taken here so
the shipped mover set stays exactly the 9 predicted databases.

**R-V3 — a NAMED element type does not bind golden's shared, named typespec.**
The pass's own residue 1, confirmed independently: a typedef of the element
(`sname126v`, `bname126v`), a typedef of the ARRAY (`srow126v`), an `enum`, a
packed `struct`, an unpacked `struct` and a class handle all give golden a
NAMED typespec with the typedef's span and a `vpiInstance`; ours gives an
anonymous `logic_typespec` / `bit_typespec` / `int_typespec`. This is exactly
BuildUVMPkg's NEW head (`enum_typespec(uvm_pkg::uvm_check_e)`) — R0's own next
pass.

**R-V4 — `var string x[N]` has no golden object at all.** Surelog reports
`[ERR:UH0701] Unsupported statement` for a `var`-prefixed block-item data
declaration and emits nothing; we emit an `array_var` either way. ONLY-OURS,
identical in pristine and patched. A golden-side gap, not ours to model.

**R-V5 — census-shape differences.** In `v126_f_stress` golden's constructor
locals hang off a `…/function(new)/begin/assignment` chain and ours off
`…/function(new)`, and golden carries no cell at all for the constructor's first
declaration. Pre-existing and identical on both binaries.

---

## 6. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `armv126.sh` | one arm: Surelog golden in **BOTH** views (`-parse` and `-parse -elabuhdm`), both frozen binaries in both views, a census of each, and the OFFICIAL `uhdm-cmp` on all four pairs |
| `cenv126.cpp` | r10uvm126's `cen126.cpp` plus the one field it was missing: the element typespec's `VpiSigned`, per kind |
| `predv126.sh` | the verifier's own a-priori mover predictor — reads only PRISTINE databases and each row's own golden, never a patched one |
| `v126_[a-f]_*.sv` | the six arms (see `ARMS.r10v126.txt`) |
| `GATES.r10v126.txt` | the full gate log, all thirteen gates, all three binaries |
| `ARMS.r10v126.txt` | the arm index and what each one asks that r10uvm126's grids do not |
