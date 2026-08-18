# r10vbuvm24 — ADVERSARIAL VERIFICATION of r10buvm24 (§ `emptyArgSlotIntZero24`)

**VERDICT: ACCEPT AS SHIPPED.**  Every headline number in the implementer's
report was reproduced bit-for-bit from binaries this verifier built itself at
BASE `c0f3a94`; the law survived a second, independently written grid of 9
files covering every axis the brief enumerates; no pristine-right ->
patched-wrong cell was found anywhere.

MEASUREMENT ONLY.  `uhdm-cmp` and `scripts/verify_golden.py` are the judges.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  `results/*.csv` were read
only and nothing was promoted.

| | |
|---|---|
| BASE | `c0f3a94` |
| worktrees | `/tmp/wt_vbuvm24` (patched), `/tmp/wt_vbuvm24pris` (pristine) |
| pristine md5 | `d35dfd84201d10e1e332201db22417fa` — reproduced |
| patched md5 | `44024e438004a20693c409a5cecefbf0` — reproduced |
| BuildUVMPkg cmp md5 (`2>&1`) | pristine `070cefa7005899f934be8d9900f37744` → patched `8f6d48af61782566449277323fcf2c19` — both reproduced, both modes byte-identical |
| patch | applies clean on a FRESH `c0f3a94`, 0 conflict markers, surface = 3 production files + `tools/probe/r10buvm24repro/` only, 0 fenced names |

## 1. WHAT WAS REPRODUCED

Builds: both binaries built here (`-j 2`, 0 errors) hash to the implementer's
md5s exactly.  (The README's phrase "reproduced the main tree's binary byte for
byte" is now STALE — the main tree has landed two passes since; the durable
claim is "= the binary of BASE `c0f3a94`".  This is the only correction.)

Gates, all re-run from the verifier's own frozen binaries and workdirs, with
`SLANG_UHDM` exported per binary and every `cmds.txt` audited BY PATH
(2 981 slang invocations per sweep, one binary path each, no main-tree binary
anywhere):

| gate | verifier's measurement |
|---|---|
| goldens | patched `PASS=23 FAIL=0`; pristine `23/0`; `SLANG_UHDM=/bin/false` → `FAIL=23 PASS=0` |
| uhdm2rtlil | `679 / 50 / 2` both modes, both binaries; `ct8rows` **0 differing ROWS** vs the committed `gate_uhdm2rtlil.csv` and vs the verifier's own pristine sweep, status AND dump, both modes |
| surelog `--mode both` | `936 CMP_EQUAL / 20 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 1 NO_UHDM / 567 SLANG_REJECT / 48 SURELOG_FAIL / 1 TIMEOUT / 2 UNTRANSLATABLE` — identical on both binaries; `ct8rows` **0 differing ROWS over 1 588** against both baselines.  **NO ROW CONVERTED.** |
| byteverify `SELFCHECK=1` | u2r **MOVERS 0 / 1358** (PATH_SETS_IDENTICAL, SELFCHECK 1357/1358); surelog **MOVERS 9 / 956**, SELFCHECK 955/956 |
| canaries | `ok=52 changed=0`, `ok=8 changed=0`; `ctcan2` PASS ×2; `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`; no fenced name in either probe dir |
| protected DBs | InterfaceModPort `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a`/`73a10e8217e5`, YosysOldOr `d68e0796d62c` SAME; **SVSwitch `4842211c4030`** and **YosysVerx `6ccda350c24a`** pins HIT |
| row heads | SeqDriver 50/50, SimpleUVM 108/108, Scoreboard 108/–, MiniAmiq 50/50, Earlgrey_0_1 216/216, Rggen 194/– unchanged; BuildUVMPkg **32 → 56**, 1 head throughout |
| implementer's grid `g24.sv` | 295/305/295 objects; MATCHING 58 → **288**, SURPLUS 247 → **7**; non-judge payload 58 → **295**, SURPLUS → **0** |

**The mover prediction was made BEFORE byteverify ran** (`VPREDICTION.txt`,
from `vfence24.py`, a lexical superset written independently) and the 9 movers
are exactly the 9 predicted.  The implementer's `fence24.py` also reproduces
exactly: u2r `1462 scanned, 0 empty slots`; surelog `1573 scanned, 62 empty
slots` splitting `9 CMP_NOTEQUAL / 6 CMP_EQUAL / 47 SLANG_REJECT`, with the
same names — and the 9 CMP_NOTEQUAL ARE the 9 movers.

**The 9 movers, scored against their own rebuilt goldens** with a
VIEW-GENERAL multiset comparator (`vcen24` + `vgrid24.py`; key = call
loc/kind/name with no view label and no argument count; payload recurses one
level into operation operands, callee arguments and `ref_obj` `Actual_group`,
which the implementer's payload did not):

| database | matching golden, pristine → patched | BROKEN-KEYS | new surplus |
|---|---|---|---|
| BuildUVMPkg ×2 | 14 228 → 14 251 (**+23**) | 0 | 0 |
| MiniAmiq ×2 | 23 224 → 23 269 (**+45**) | 0 | 0 |
| SeqDriver ×2 | 22 189 → 22 234 (**+45**) | 0 | 0 |
| SimpleUVM ×2 | 13 411 → 13 434 (**+23**) | 0 | 0 |
| Scoreboard (default) | 13 546 → 13 569 (**+23**) | 0 | 0 |

**295 cells to golden, 0 away, 0 BROKEN keys, and 0 surplus object that was
not already pristine surplus** (checked per key as `(Q−G) − (P−G)`).  The
order-blind path-normalised dump diff carries no collateral: for BuildUVMPkg
every one of the 306 changed lines is either a new placeholder line (23 ×
`vpiConstType:7` / `INT:0` / `\_constant`) or a removed clone line (the `-1`
operations, the `"."` byte strings, the `UVM_NORADIX` enum ref, and the
`vpiParent:` lines that pointed at `print_field_int` / `read` / `write` /
`open_recorder`).

Golden `BuildUVMPkg` holds exactly **23** located, unparented `INT:0 ct 7`
call arguments over **12** call sites, 11 sites × 2 copies + 1 × 1 — the
implementer's count, independently recomputed.

`ct92cen` (§ uvm92) and `ct94cen` (§ uvm94/95) were run on all 9 movers:
`EXPM_N=0` everywhere and every pinned count hit (SeqDriver 47, SimpleUVM 25,
Scoreboard 25, MiniAmiq 50, BuildUVMPkg 26); `ct94cen --all` rows are
BYTE-IDENTICAL pristine vs patched, `RNG_N=0 IPS_N=0`.  The name-text laws
hold.

## 2. THE LAW, RE-DERIVED AND STRESSED

Surelog's decode was read at the source, not taken on trust:
`CompileHelper::compileTfCallArguments`, the by-position `else` branch — it
mints `INT:0 / "0" / 64 / vpiIntConst`, calls
`populateCoreMembers(argumentNode, argumentNode, c)` and, alone among the
sibling branches, never sets `VpiParent`; `io_decls` is fetched at the top of
the routine and never read on that path, which is why the default's kind
cannot matter.  `constant::Compare` reads `basetype_t::Compare` then
`VpiConstType` and nothing else; `expr::Compare` reads `VpiDecompile`,
`VpiSize`, `Typespec`.  `VpiValue` is never compared.

The verifier's own grid is **9 files, scored against Surelog in BOTH views**:

| file | what it adds | result |
|---|---|---|
| `gv24a.sv` | 18 default shapes (incl. **concat** `{8'h1,8'h2}`, **time** `10ns`, **unpacked-array** `'{1,2,3}`, localparam ref), 11 omission forms (incl. `g4(1,,,4)`, `g4(,,,)`), callee kinds: package fn/task, class method bare/handle/`this`/OOB, **static** `bv24::sm`, **virtual through a base handle**, constructor, `super.new`, **interface** function AND task, module fn/task, homes: class, package, module `initial`/`always`/function, **generate block**, **program**, **3 module instances** | 367 golden objects; matching **69 → 351**; 0 broken |
| `gv24g.sv` | the INTERACTION grid — an empty slot in the same call as an actual governed by a bind-window law (class field, enclosing formal, **package variable**, block-local in a named block, control body, `for` body, dynamic-array element, `new[]`) | **8 → 64 of 64**, SURPLUS → **0**, and every `Actual_group` binding (`logic_net` / `int_var` / `array_var` / NULL) is IDENTICAL pristine vs patched |
| `gv24h.sv` | parameterised class (2 specialisations), generate-`if`, generate-`case`, **localparam initialiser**, `fork/join_none` | **12 → 33 of 33**, SURPLUS → 0 |
| `gv24i.sv` | arity 1 and 2, `y2(,2)`, `y2(,)`, `y2(1,)`, an **output** formal ahead of a defaulted input, a **`ref`** formal, a **package-qualified** call | **6 → 30 of 30** scored WITH the argument count in the payload |
| `gv24j.sv` | a **chained** call on a call result, a triple-nested empty slot, an empty-slot call inside a `$display` argument, a call in a **constraint** | **3 → 21 of 24**; the 3 are R-CHAIN (below) |
| `gv24c.sv` | **DPI import with defaulted formals** | **0 → 6 of 6** |
| `gv24b.sv`, `gv24e.sv` | NEGATIVE CONTROLS: a module-instance port list `leafv24 u0 (aa, , cc);` + a named-empty `.b()`, and a `foreach (B[q,,r])` index list | databases **BYTE-IDENTICAL** pristine vs patched in both views |
| `slangreject/gv24d.sv`, `slangreject/gv24f.sv` | `$past(x,,,clk)` and a sequence instance with an empty slot | **both SLANG_REJECT** on both binaries — R-SYS confirmed, nothing to compare |

The LEADING-slot rule was re-measured, not inherited: golden's `g3(,2,3)` is
TWO arguments, `g3(,,3)` two, `g3(,,)` two, `g4(,,,)` **three**, `y2(,2)`
**one** — and the patched binary matches all of them with the count in the
payload.  Surelog's `NodeId argumentNode = fC->Child(Arg_list_node);` is why:
the parse yields no node for the leading slot.

## 3. WHAT THE BOUNDARY GATE SAW

A COPY of the WHOLE `tools/probe` tree, no path filter, `.sv` AND `.v`,
per-FILE and per-DIRECTORY, both views, arm list on fd 3, children
`</dev/null`, `PROCESSED == LISTED` asserted, rc recorded per cell, symmetric
rejects:

```
file/def   PROCESSED=3180 LISTED=3180 DIFFER=4 REJ 132/132
file/elab  PROCESSED=3180 LISTED=3180 DIFFER=4 REJ 142/142
dir/def    PROCESSED=1440 LISTED=1440 DIFFER=5 REJ 115/115
dir/elab   PROCESSED=1440 LISTED=1440 DIFFER=5 REJ 120/120
```

The differing arms are `r10buvm24repro/g24.sv` and `r10vbuvm24repro/gv24a.sv`
/ `gv24c.sv` (the POSITIVE CONTROLS), `r10buvm22repro/g22.sv` (R-ASSOC), and
the parallel-parse COIN arms.  **No bind-window arm moved** — buvm3–15,
uvm82–91, sd8–12, § `classArgBind12`,
§ `retNameRecvCollapseArgsBindLikeBody15`, § `collArgNamedBlkLocalNoBind15`,
§ `controlBodyNoBind28`, § `blkLocalSameCtrlDepthArgBinds57/64`,
§ `pkgVarBindsOnlyThroughInstance88`, § `formalDefaultBindsLikeBody13`,
§ `classInBodyRecvCallArgNoBind52`, § `superNewFormalBinds28`,
§ `newArrayArgNoBind16`, § `writtenCallArgs16`,
§ `genLpPortConnCopyableOnly11v`, § `dottedIdxRecvFromSyntax23`, uvm81's
formal contest and sd10/sd12 `scopedReach` are all absent from every
`differ.txt`.

**Correction to the implementer's boundary write-up:** the dir-mode DIFFER
count is NOT stable at 4.  This verifier's first dir run reported **5**, the
extra arm being `r10uvm88repro` with an ORDER-BLIND diff of **0**.  Four
pristine runs of that directory hash identically, but four PATCHED runs give
`fe1893…` three times and `4d36ce…` once, and the difference is a
`vpiTaskFunc` list-ORDER flip on `p3::base3::oob_base` — the documented
parallel-parse coin, in a directory containing **zero** lexical empty slots.
`r10uvm88repro` is therefore a THIRD known coin arm alongside `r10uvm75repro`
and `r10uvm76repro`, and any future pass that sees it in a boundary
`differ.txt` should sort the dumps before believing it.

## 4. RESIDUES THE VERIFICATION ADDED OR SHARPENED

* **R-MIXED (new, judge-visible, not in the implementer's list)** — a
  POSITIONAL-THEN-NAMED actual list.  Golden gives `g3(1, , .c(3))` **five**
  arguments (`1`, PH, then one slot PER FORMAL: PH, PH, `3`) and
  `g3(1, 2, .c(3))` five as well — Surelog runs the by-position arm and the
  by-name slot filling over the SAME list.  We emit three in both cases, on
  BOTH binaries.  PRE-EXISTING and unchanged by this pass (`emptyArgSlots24`
  refuses any list with a named argument, correctly), but it is a real
  judge-visible cell that neither § `namedTfArgsFormalSlots4` nor this law
  covers.  Grid `gv24a.sv:102-103`.  No corpus cell (`fence24.py`'s 62 contain
  no mixed list).
* **R-CHAIN (new)** — `mk(1,,3).val(1,,3)`: golden keeps ONLY the receiver
  `func_call mk` at `31:11` and emits no `val` call at all; we emit
  `method_func_call val` at `31:20` and no `mk` at `31:11`.  Pre-existing
  shape difference; the patch fixed the PAYLOAD of our `val` call and changed
  nothing else.  Grid `gv24j.sv:31`.
* **R-ASSOC (confirmed, and worse than "noisy")** — `g22.sv`'s
  `typedef int ka_str_t[int]`.  Golden's `vpiRightRange` is a `constant`
  `STRING:"associative"` `ct 6`; ours is an `operation` (`opType 11`) over an
  8-digit `UINT` that CHANGES WITH THE BINARY (`22197601` pristine →
  `22205793` patched, `22198457` → `22206649` at the sibling site; delta
  exactly 8192).  Each binary is deterministic across repeated runs, so this
  is a **leaked address / uninitialised read**, not a race — which means ANY
  future relink can move it.  Corpus reach is **0 and now proved**: the only
  9 databases that changed at all contain no `UINT`/`INT` literal of 7+ digits
  among their changed lines.  It deserves its own pass; the emitter side to
  look at is the assoc-array range construction near
  `src/UhdmExporter.cpp:2475` / `:3871` (both of which mint the correct
  `STRING:associative` marker — the `[int]`-keyed case is reaching neither).
* **R-TS (confirmed, and the source of the one BROKEN key)** — the io_decl
  default `int b = help24(2)`'s own argument constant carries a
  `ref_typespec` golden has not.  On the verifier's grid this shows as ONE
  broken key (`hv24` at `46:52`, 10 → 0): pristine "matched" golden there only
  because 13 CLONE copies of the same call carried the right payload and the
  multiset intersection paired them off; the patch deleted the clones and
  exposed a mismatch that was always there.  Per OBJECT nothing went from
  right to wrong — the 10 io_decl objects are byte-identical on both binaries
  — and the judge's tree walk was strictly improved (golden has no call at
  those call sites at all).  A multiset scorer will keep reporting this as
  "broken" until R-TS is fixed; that is a scoring artifact, not a regression.
* **R-LEAD, R-NAMEDEMPTY, R-SYS, R-OVERRUN** — all confirmed as stated.
  R-OVERRUN sharpened: `y1(,)` on a ONE-formal function is a SLANG REJECT
  ("too many arguments … expected 1 but 2 were provided") where Surelog
  accepts it, so the shape can never reach a comparable row.
* **super.new copy count** — our grid emits 3 elab copies of `super.new`
  where golden emits 2, on BOTH binaries.  Pre-existing, unchanged.

## 5. R0 CONFIRMED

The patched head was decoded from the pristine log independently and agrees
with the implementer: `array_var` (golden) vs `class_var` (ours) for the
`foreach` loop variable of the queue `uvm_object_wrapper uvm_deferred_init[$]`
at `uvm_pkg.sv:9847`, typed from the ARRAY on golden and from the ELEMENT on
ours.  The failing field is `VpiType` — `BaseClass::Compare`'s first test —
and the `array_typespec` vs `class_typespec` mismatch below it is the same
defect one level down.  56 lines, 1 head, byte-identical between modes.

## 6. HOW TO REPRODUCE THIS VERIFICATION

```bash
bash vgridrun.sh gv24a.sv <pristine> <patched> <wd> <cen bin>   # any grid file
python3 vgrid24.py <wd>/cen.g.txt <wd>/cen.pris.txt <wd>/cen.pat.txt [--x] [--narg] [--show]
python3 vfence24.py <sweep workdir>                              # the mover fence
bash vmovers24.sh <pris sl wd> <pat sl wd> <cen bin> <out> BuildUVMPkg MiniAmiq …
PRISTINE=… PATCHED=… ROOT=<a COPY of tools/probe> MODE=file|dir VIEW=def|elab bash vbound24.sh
```
`vcen24.cpp` builds with the same recipe as `r10buvm24repro/build24.sh`.
