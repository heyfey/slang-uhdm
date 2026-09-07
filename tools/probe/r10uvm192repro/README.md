# r10uvm192 — § `pkgTfBodyCmViewClone192` — **A `C::m()` WRITTEN IN THE BODY OF A SUBROUTINE THE PACKAGE ITSELF LISTS BINDS THAT LISTING'S OWN `C::m` ENTRY** — the BuildUVMPkg ×2 300-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list — `predict192.sh` and `cen192.sh` read that list
rather than spelling it, and the wide boundary compiles `tools/probe` arms
exclusively and dispatches no corpus test at all.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `6ee26f73` |
| pristine binary | md5 `2b2aa40f9a4ceee88eda2e4ea249e19e`, built from this pass's OWN worktree at a clean `6ee26f73` and frozen `chmod 555` before any sweep — **byte-identical to the master's own build at that commit** |
| patched binary | md5 `305893f7c07f44a90a61eb96230f2f3c`, frozen `chmod 555` |
| production surface | `include/UhdmExporter.h` (the declaration and the Surelog citation), `src/ParamEmit.cpp` (the law, its four fence terms and the golden tables that convict each of them), `src/UhdmExporter.cpp` (one call, design-final, right after § 111's loop) |
| probe surface | `tools/probe/r10uvm192repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **BuildUVMPkg default and testflags, 300 cmp lines, ONE head each → 31**, on a **different object of a different kind** (§7). The two modes' databases are BYTE-IDENTICAL before (`f3744d2da5c0`) and after (`c187864f28a6`). |
| corpus rows changed | **0** — both corpora, both modes. `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column: 1588 surelog rows, 731 + 731 uhdm2rtlil rows. |
| byte movers | **9 / 956** surelog — BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM (both modes) and Scoreboard/default, **every one PREDICTED BY NAME, with its cell count, before the patched sweep ran**, from the 956 PRISTINE databases alone. **0 / 1358** uhdm2rtlil, also predicted (0 candidate cells over all 1358 pristine databases). |
| the census (nine UVM DBs × both modes) | 118 candidate cells. **TO-GOLDEN 68 / AWAY-GOLDEN 0 / MOVED-WRONG 0 / MISSED 0**, and the 50 the fence holds back are all cells golden also leaves alone. Whole-call join: AGREE 129 994 → **130 062** (+68), golden-only 23 403 → 23 335 (−68), ours-only likewise. `moves-left = 0` in every mover — the law is at fixpoint. |
| the grids (4 arms, both views, one REAL Surelog golden each) | **TO-GOLDEN 40, AWAY 0, MOVED-WRONG 0, MISSED 0**; all eight verdicts PASS; every rc recorded and 0 nonzero. |
| the WIDE boundary (5137 arms, both views) | `LISTED=5137 PROCESSED=5137 PRODUCED_DBS=4972`, **RC_DIFFS 0**, MOVED_ARMS **21** — 4 of them this pass's own (the positive control). Every one of the other 17 is scored against GOLDEN: **TO-GOLDEN 122, AWAY 0, MOVED-WRONG 0**. |
| the FLOOR | uvm185's arms and BOTH inheritance fences, uvm190's, uvm187's, uvm188's, uvm170's arms and both fences, uvm82–91, buvm3–15, sd8–12 — **33 families, 604 arms, byte-identical**, absent from the moved list entirely (§8). No static-address false mover appeared. |
| the LISTING itself | **UNTOUCHED, and already exact.** This pass changes no listing code. `ct192cen`'s `SUB` section counts every subroutine object: golden and ours agree to the object on all nine UVM databases (BuildUVMPkg 5275 = 5275, MiniAmiq 6941, Scoreboard 4884, SeqDriver 6628, SimpleUVM 4809), and every count is identical before and after. "A method golden lists once stays listed once" holds by construction. |
| gates | goldens **23/0**, negative control **0/23**; canaries `ok=52`/`ok=8` `changed=0`; `ctcan2` PASS ×2; `canaudit` PASS; all 10 protected databases SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `6ee26f73` worktree; it
came out byte-identical to the master's. Its own 956-row surelog sweep and both
1358-row uhdm2rtlil sweeps reproduced the committed baselines row for row
(`ct8rows` 0 differing rows, status AND dump column). Every `cmds.txt` in both
sweeps names this pass's own frozen binary, audited BY PATH (2981 rows).

`rowheads.sh` on that sweep put BuildUVMPkg at **300 cmp lines, ONE head**, both
modes, the same database — the R0 r10uvm190 named.

```
LHS golden  function: (uvm_pkg::uvm_root::get), id:60621, @38754:1-38757:12
            |vpiParent: package uvm_pkg, id:60163      |vpiName: uvm_root::get
RHS ours    function: (get),                 id:94911, @38754:1-38757:12
            |vpiParent: class_defn uvm_pkg::uvm_root   |vpiName: get
```

Every other compared field of the pair agrees, including `vpiInstance` (the
package on both sides). The one compared difference is `VpiName`, on
`BaseClass::Compare`'s name line.

## 2. THE BRIEF'S FRAMING, REFUTED FIRST — WE LIST IT TWICE TOO

The brief says golden "lists the same class method twice … where we list it
once". **That is false**, and `ct192own`'s TWIN TEST says so on the pristine
database:

```
GOLDEN  function(get)@38754:1-38757:12 #786     parent < class_defn:uvm_root < package:uvm_pkg
        function(uvm_root::get)        #60621   parent < package:uvm_pkg
OURS    function(get)@38754:1-38757:12 #94911   parent < class_defn:uvm_root < package:uvm_pkg
        function(uvm_root::get)        #141102  parent < package:uvm_pkg
```

Two objects on each side, the same two names, the same spans. STEP 3 goes
further: **the two package listings agree index for index** — 52 entries in one
view and 979 in the other on BOTH sides, and index 336 of the 979 listing holds
`function(uvm_root::get)` on both. Nothing about the LISTING is wrong.

## 3. DECODING THE JUDGE — WHICH EDGE IT ACTUALLY TOOK

`ct192own` links the SAME generated `Compare` the judge does. Because BOTH sides
of this head are present (a `VpiName` failure, not r10uvm190's `LHS: <null>`),
the mirror scan is not enough: both databases must be scanned and the pairing
proved. STEP 1 enumerates every edge landing on each side's head with its vector
index and neighbours; STEP 4 then re-compares each face-matched OWNER PAIR in a
FRESH `CompareContext` and reports which reproduces the head.

```
PAIR golden begin()@38756:2-38756:23        ours begin()@…      r=0  (no head)
PAIR golden class_var()@38754:10-38754:18   ours class_var()@…  r=0  (no head)
PAIR golden func_call(uvm_root::get)@9855:11-9855:19 #64480
     ours   func_call(uvm_root::get)@9855:11-9855:19 #2551
     r=14  LHS=function(uvm_root::get)#60621  RHS=function(get)#94911   <== REPRODUCES THE HEAD
```

**The failing edge is `func_call::Function` (vpiType 20), singular** — the call
`top = uvm_root::get();` at `uvm_pkg.sv:9855`, inside the package function
`uvm_init`. The package `Task_funcs` vector (vpiType 127) that also lands on
golden's head is NOT the edge: our own package listing holds `#141102` at that
same index 336, so that vector pairs correctly. **This is a BINDING law, not a
listing law.**

## 4. DECODING SURELOG

**`CompileHelper::getTaskFunc`** (`src/DesignCompile/CompileExpression.cpp:349-382`)
resolves a written call name in this order: (1) if the name holds `::`, treat the
head as a PACKAGE name — `design->getPackage("uvm_root")` is null for a CLASS, so
a `C::m` spelling falls straight through; (2) walk the CURRENT component and its
parents, linear-scanning `comp->getTask_funcs()` for `tf->VpiName() == name`. A
package's own listing entry for an out-of-body class-method definition is named
`C::m` verbatim, so step (2) hits it — and the CALL and the ENTRY it hits belong
to the same package copy, because each copy is compiled in its own component.

**`UhdmWriter::writePackage`** (`src/DesignCompile/UhdmWriter.cpp:1237-1274`) then
splits the two copies apart:

```cpp
if (funcName.find("::") != npos) {
  … for (auto cl : *dest_classes) if (cl->VpiName() == className) {
        tf->VpiParent(cl);  cl->Task_funcs()->push_back(tf);  foundParentClass = true; }
  if (foundParentClass) tf->VpiName(funcName);        // RENAMED to the bare `m`
  else { tf->VpiParent(p); p->Task_funcs()->push_back(tf); }   // stays `C::m`
```

and it is called TWICE (`UhdmWriter.cpp:4944` with `elaborated=true` on the
elaborated `Package`, `:4979` with `false` on `pack->getUnElabPackage()`). Only
the ELABORATED view's `dest_classes` carries the classes, so **one Surelog rule
prints as two different bindings**.

`ct192view` measures which view is which — and corrects the natural guess:

```
GOLDEN AllPackages uvm_pkg #60163 VpiTop=0 Task_funcs=979 qualified=927 Class_defns=0   class_methods=0
GOLDEN TopPackages uvm_pkg #1     VpiTop=1 Task_funcs=52  qualified=0   Class_defns=327 class_methods=4226
OURS   AllPackages uvm_pkg #2     VpiTop=0 Task_funcs=979 qualified=927 Class_defns=0   class_methods=0
OURS   TopPackages uvm_pkg #2752  VpiTop=1 Task_funcs=52  qualified=0   Class_defns=327 class_methods=4226
```

The **DEFINITION** view (`AllPackages`) is the one holding the flat qualified
listing. § `pkgVarInitCmViewClone111`'s committed golden table says exactly this
for a package VARIABLE INITIALIZER; this pass measured it again rather than
carrying it over, because that table was written on the uvm-1.2 include tree and
this row's golden is the 1800.2-2017-1.0 `pp_output` tree.

**THE GOLDEN TABLE** (`ct192cen`, one row per CALL keyed on span × call kind ×
written name × caller scope × top-listing size; the DEF/ELAB view is kept OUT of
the key and separated by the listing-size column instead — RESUME §9's listcheck
lesson). Every `C::m`-spelled call in BuildUVMPkg's `uvm_pkg`, all 16 per view:

| view | golden binds | n | ours (pristine) |
|---|---|---|---|
| DEF (`AllPackages`, 979) | the DEF listing's own `C::m` entry | **13** | the class_defn's bare method |
| DEF (`AllPackages`, 979) | a package sub, bare-named | 3 | the same — agrees |
| ELAB (`TopPackages`, 52) | the class_defn's bare method | 16 | the same — agrees |

The three that already agree are the `uvm_pkg::m_uvm_string_queue_join` calls —
PACKAGE-qualified, § `pkgDefCallBindsOwnListing173`'s population, which that law
already decided. The ELAB row is the same rule reaching a view whose listing
carries no `C::m` entry at all, so nothing there can move.

## 5. DECODING SLANG — AND THE TERM THE uvm-1.2 ROWS CONVICT

We already emit both listing objects with both names (§2) and we already have
this law at the OTHER call site: § `pkgVarInitCmViewClone111`
(`ParamEmit.cpp`, `bindPkgVarInitClassMethodClones111`) walks a package
VARIABLE's initializer expression and re-points exactly this link. It never
walks the package's own `Task_funcs` BODIES, which is where all 13 head cells
live. § `pkgDefCallBindsOwnListing173` (`UhdmExporter.cpp` ~4897) sees these same
calls and correctly REFUSES to move them to the ELABORATED twin — but "leave
alone" left them on the class method, not on the def twin.

The fix is one gated pass, design-final, immediately after § 111's loop (§ 111's
own measured placement: `drainScopedCallBind26` / `drainCollapseLink172` are what
put the class_defn's method on these calls in the first place, which is this
law's first fence term).

**THE FENCE HAS FOUR TERMS, AND THE THIRD WAS CONVICTED BY A REFUTATION.** The
first version scoped the law to "the view's own entry" and scored, on the nine
pristine UVM databases:

```
             cells   verdict
home  bodies    68   TO-GOLDEN 68 / AWAY  0
other bodies    48   TO-GOLDEN  0 / AWAY 48        <- adpcm_pkg, svaunit_pkg
```

A package that wildcard-imports another carries `clone_tree` copies of every
body it imports (`CompileHelper::importPackage`,
`src/DesignCompile/CompileHelper.cpp:299-330`, under an `ElaboratorContext`), and
golden keeps THOSE copies' calls on the class method. Two readings of the split
score identically on all 118 UVM cells (48 N/N, 70 Y/Y) — the callee's home and
the caller's home — so the corpus alone cannot separate them. **Arm C does:**
`forgePkg` wildcard-imports `hearthPkg` and then writes its OWN body
`Bellows::ownCaller` calling the IMPORTED class's static `Anvil::weight()`, and
golden binds `forgePkg`'s own `Anvil::weight` clone entry there. The callee-home
reading scored those two cells MISSED; the caller-home reading gets them right,
and re-scores every UVM cell unchanged. **The law is the CALLER's home.**

```
FENCE 1  the call is ALREADY bound to a CLASS_DEFN-parented method
         (excludes the 3 package-qualified calls and every unbound call, and is
          why this pass cannot fight § 173)
FENCE 2  the call sits in the BODY OF A SUBROUTINE THE PACKAGE LISTS DIRECTLY —
         walking out, the first scope reached is a function/task whose own
         parent is a package (a class_defn body is the ELAB view; a package
         VARIABLE initializer is § 111's cell)
FENCE 3  that body is one this package OWNS — if the subroutine is named `C::m`,
         `C` must be a class_defn of a package with this package's name; an
         unqualified free function counts as owned
FENCE 4  the target is an entry of THAT SAME package view whose VpiName equals
         the WRITTEN call name EXACTLY, of the call's own kind (a `task*` in
         `Function()` would be a link error — § 26's guard)
```

No NAME is written anywhere in this pass — only a link is re-pointed — so the
recorded "naming is context-dependent, do not uniformly fix `pkg::pkg::`" memory
is respected.

## 6. THE MOVERS, PREDICTED BY NAME AND ATTRIBUTED

`predict192.sh` transcribes the fence into `ct192cen`'s `PRED` section and runs
it over PRISTINE databases only. Before the patched binary produced anything:

```
PREDICT-MOVER default/BuildUVMPkg   move-cells=13 wide-no-entry=1
PREDICT-MOVER default/MiniAmiq      move-cells=6
PREDICT-MOVER default/Scoreboard    move-cells=6
PREDICT-MOVER default/SeqDriver     move-cells=6
PREDICT-MOVER default/SimpleUVM     move-cells=6
PREDICT-MOVER testflags/{BuildUVMPkg 13, MiniAmiq 6, SeqDriver 6, SimpleUVM 6}
-- dirs=1573 no-ours=617 PREDICTED MOVERS=9   (uhdm2rtlil: dirs=1462 MOVERS=0)
```

`byteverify.sh SELFCHECK=1` returned **exactly those 9 of 956**, and **0 of
1358** on uhdm2rtlil. `PATH_SETS_IDENTICAL` on both; SELFCHECK flagged 955/956
and 1357/1358, so the gate can see.

**Scoreboard/default is in the mover set BY PREDICTION (6 real cells), not by the
coin.** RESUME §9's coin is proven to have sat out this run: the ORDER-BLIND
whole-dump diff is **0 lines on all nine movers**.

**AND THAT ZERO IS ITSELF A RECORDED FACT.** `uhdm-dump` renders a `vpiFunction`
edge by the callee's SYNTHESISED `vpiFullName`, not by its `VpiName`:

```
            |vpiFunction:
            \_function: (uvm_pkg::uvm_root::get), line:38754:1, endln:38757:12     <- pristine
            \_function: (uvm_pkg::uvm_root::get), line:38754:1, endln:38757:12     <- patched
```

Both candidate objects carry the same fullname and the same span, so **the
whole-dump diff is structurally BLIND to this law** — 0 sorted lines on a
database whose bytes provably moved. The judge is not blind: `BaseClass::Compare`
reads `VpiName` (`get` vs `uvm_root::get`), which is the head that cleared. The
attribution therefore uses the COMPARE-VISIBLE census instead, and it is exact:

```
AGREE       129 994 -> 130 062   (+68, exactly the 68 predicted cells)
golden-only  23 403 ->  23 335   (-68)
ours-only    23 403 ->  23 335   (-68)
TO-GOLDEN 68  AWAY-GOLDEN 0  MOVED-WRONG 0  MISSED 0   moves-left 0 in every mover
```

## 7. THE HEAD AFTER — AND R0

```
BuildUVMPkg default and testflags, 300 -> 31 cmp lines, ONE head each,
both databases byte-identical to each other (md5 c187864f28a6)

LHS golden  bit_select: (uvm_pkg::uvm_packer::unpack_string::unpack_string),
            id:72450, @22952:7-22952:23
            |vpiParent: \_assignment: , id:72448, @22952:7-22952:52
            |vpiName:unpack_string
            |vpiIndex: \_ref_obj: (…::unpack_string::i), id:72449, @22952:21-22952:22
                        |vpiActual: \_int_var: (…::unpack_string::i), id:72426, @22937:7
RHS         <null>
```

**R0** — a MISSING OBJECT of a different kind and family: golden's
`uvm_packer::unpack_string` assigns into a **`bit_select` on the function's own
implicit return variable**, indexed by the loop variable `i`
(`unpack_string[i] = …` at uvm_pkg.sv:22952), and we emit no such object. Per
RESUME §9 the SINGULAR `SafeCompare` overload names the VALUE with
`RHS: <null>`, so the owner is the `assignment` above it and the next pass should
run `ct192own`'s mirror scan (or r10uvm164's `ct164own`) to name it from the
judge before writing anything — a return-variable-as-array-target law, adjacent
to r10uvm185's return-variable family but about the STATEMENT TARGET, not the
declaration.

**R1 — the extra-copy multiplicity.** In the four grid arms our databases carry
more call objects than golden's (`ours-only` is nonzero after the patch in every
arm: e.g. arm C def 8 vs golden-only 1). We materialise wildcard-import clone
BODIES that golden leaves empty, or emits fewer of. Wholly untouched here.

**R2 — two abstentions the boundary named, unchanged before and after.**
`r10v144repro/v144_a_homes.sv` has 2 cells where golden binds a `program`-scoped
`si` and we bind a `class_defn` method of the same name; `r10vbuvm32repro/vb32m1.sv`
has 3 where a PACKAGE-qualified `q32::qfree32` binds golden's bare-named package
free function while we bind a same-named class method. Both are name-collision
residues of § 173's family, not this law's — the fence correctly abstains (no
entry of the written name exists), and the cells are identical under both
binaries.

**R3 — the nested out-of-body method is UNREACHABLE, not agreeing.** slang
refuses `function int Outer::Inner::spool();` ("expected subroutine name" / "use
of undeclared identifier 'Inner'"), so arm B measures the nested row with an
IN-BODY method instead. Patching slang is out of scope; recorded so the next
pass does not read that row as a passing grid cell.

## 8. THE BOUNDARY AND THE FLOOR

```
LISTED=5137 PROCESSED=5137 PRODUCED_DBS=4972 MOVED_ARMS=21 RC_DIFFS=0
```

Subdirectory arms are compiled (the list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path). Four of the 21 are this
pass's own `grid192/g192_*.sv` — the POSITIVE CONTROL, without which the gate
could not be shown to see. **Each of the other 17 was rebuilt with a REAL Surelog
golden in BOTH views and scored:**

| arms | TO-GOLDEN | AWAY | MOVED-WRONG |
|---|---|---|---|
| `r10buvm32repro/g32a{1,2,3}.sv` | 18 + 16 + 6 | 0 | 0 |
| `r10uvm144repro/g144_{c,d,e}.sv` | 12 + 2 + 2 | 0 | 0 |
| `r10uvm150repro/g150_d.sv`, `r10v150repro/v150_c.sv` | 2 + 2 | 0 | 0 |
| `r10v127repro/arms/v127_a_callee.sv` | 2 | 0 | 0 |
| `r10v144repro/v144_{a,b,c,d}*.sv` | 4 + 2 + 6 + 4 | 0 | 0 (2 abstentions, R2) |
| `r10vbuvm32repro/vb32{e1,m1,r3,s1}.sv` | 6 + 30 + 4 + 4 | 0 | 0 (3 abstentions, R2) |
| **total** | **122** | **0** | **0** |

**THE FLOOR IS UNTOUCHED.** Every family the brief names as must-stay is absent
from the moved list — verified by name, not by assumption:

```
uvm185 (5 arms, BOTH inheritance fences)  uvm190 (4)  uvm187 (6)  uvm188 (4)
uvm170 (5 arms, both fences)  uvm82-91 (113)  buvm3-15 (119)  sd8-12 (347)
33 families, 604 arms, MOVED = 0
```

r10uvm190's R5 static-address false mover did not appear: all 21 moved arms are
accounted for by content.

## 9. THE FILES

| file | what it is |
|---|---|
| `ct192cen.cpp` | the CALL-BINDING census — `CALL` (every call, its caller scope, its bound subroutine's face, its top-listing size and its parent-kind chain), `SUB` (every subroutine object, for listing multiplicity) and `PRED` (the production fence transcribed term for term, so a pristine database names the movers) |
| `ct192own.cpp` | the owner-finder for a head whose BOTH sides are present: every edge landing on each head with vector index and neighbours, the TWIN TEST, the listing census, and the DESCENT TEST that names the edge the judge took |
| `ct192view.cpp` | the VIEW MAP — AllPackages vs TopPackages, `VpiTop`, and each package's qualified-entry / class-method populations |
| `build192.sh` | builds all three against `~/.local` |
| `predict192.sh` | the mover set from PRISTINE databases alone; reads the fence list out of `canaudit.sh` rather than spelling it |
| `cen192.sh` | the corpus census driver — golden found through each row's OWN `cmds.txt`, never guessed from a test name |
| `score192.py` | the golden × pristine × patched MULTISET join and its verdict (`--ours2` for the after column) |
| `grid192.sh` / `scoregrid192.sh` | the arm driver (one REAL Surelog golden per arm, both views, every rc recorded) and its scorer |
| `attrib192.sh` | the ORDER-BLIND whole-dump attribution (the instrument that proved the dump is blind to this edge, §6) |
| `bound192.sh` | the wide boundary gate |
| `grid192/g192_a_kinds.sv` | callee kind × caller site: in-body / extern out-of-body static function / static task / constructor / non-static, called from an out-of-body method body, a package free function, a package variable initializer and a module |
| `grid192/g192_b_classes.sv` | class shape: plain / parameterized / nested / derived / cross-shape |
| `grid192/g192_c_home.sv` | the own-body vs import-clone split — the arm that REFUTED the callee-home reading |
| `grid192/g192_d_order.sv` | the arm that TESTS rather than agrees: a free function colliding with a method name, CASE, declaration ORDER, self-qualified calls, the same call twice and nested in an argument |
| `DECODE.` `OWNER.pristine.` `VIEWS.` `HEAD.before.` `HEAD.after.` `CENSUS.` `GRIDS.` `PREDICT.surelog.` `PREDICT.u2r.` `MOVERS.` `BOUNDARY.` `BOUNDARY_MOVERS.` `GATES.r10uvm192.txt` | the evidence |

## 10. REPRODUCING

```sh
./build192.sh                                             # the three instruments
CEN=/tmp/r10uvm192_cen/ct192cen ./predict192.sh <pristine wd> PREDICT.txt
CEN=… ./cen192.sh <wd> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg
python3 score192.py <pristine censuses> [--ours2 <patched censuses>]
CEN=… ./grid192.sh grid192/g192_c_home.sv <pris> <patched> <wd> && ./scoregrid192.sh <wd> c_home
ct192own <golden> <ours> uvm_pkg          # the head, both sides, and the descent test
ct192view <db> <tag>                      # which view is which
./attrib192.sh <patched wd> <pristine wd> <outdir> <rel...>
PRIS=… PATCHED=… ./bound192.sh <copy of tools/probe> <outdir>
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <wd> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
bash canaudit.sh canaries.sh ctcan2.sh
```
