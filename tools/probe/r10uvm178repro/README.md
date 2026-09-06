# r10uvm178 — § `pkgCloneParamRefStaysBare178` — **A PACKAGE PARAMETER READ INSIDE A WILDCARD-IMPORT CLONE KEEPS A BARE `ref_obj`; ONLY THE PARAMETER'S HOME LISTING BINDS** — the SeqDriver ×2 and MiniAmiq ×2 33-line head CLEARED

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
WAS CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The four slang-fenced tests were
never dispatched and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `4b2b5d06` |
| pristine binary | md5 `252ab5fad779054d39ef74d7dde18edc`, built from this pass's OWN worktree at a clean `4b2b5d06` and frozen `chmod 555` before any sweep.  It is BYTE-IDENTICAL to the binary the campaign landed at this BASE, and its own 1588-row surelog sweep reproduced `results/golden_surelog.csv` **row for row** before a line of the patch was written. |
| patched binary | md5 `1fc0285162673a878ae95a50430f4126`, frozen `chmod 555` before any sweep.  The patch applied to a **FRESH `4b2b5d06` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on. |
| production surface | `src/ExprEmit.cpp` — **ONE gated suppress** (one `if` around a pre-existing three-way bind, plus the two predicates it reads) inside the package-parameter arm, and the decode.  Nothing else. |
| probe surface | `tools/probe/r10uvm178repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default+testflags and MiniAmiq default+testflags, 33 cmp lines, ONE head each — CLEARED.**  33 → **142** (SeqDriver) and 33 → **116** (MiniAmiq); the head OBJECT changed in all four (§8), and `UVM_STR_CRC_POLYNOMIAL` no longer appears anywhere in the log. |
| every other row's head | cmp log **BYTE-IDENTICAL** — SimpleUVM ×2, Scoreboard/default, BuildUVMPkg ×2, Earlgrey_0_1 ×2, Rggen/default. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against the committed baselines AND against this pass's own pristine sweeps. |
| byte movers | **4 / 956** surelog, **all four PREDICTED BY NAME from pristine databases before the patched sweep ran**; **0 / 1358** uhdm2rtlil, also predicted (zero). |
| the mover attribution | whole-dump, workdir-normalised, ORDER-BLIND diff per mover: **72 lines, every one a REMOVAL, 0 additions** — 36 `vpiActual:` edges and their 36 targets, one per predicted face cell.  Nothing else in any of the four databases changed. |
| the census (nine UVM row-modes, three families) | PREF (the law's family) **TOGOLD 144, AWAY 0, MOVED-WRONG 0**; REF (**every** reference in the database, 539 374 rows per binary) **TOGOLD 72, AWAY 0, MOVED-WRONG 0**; OBJ **0 rows moved** — nothing created, destroyed or re-typed. |
| the corpus-wide census | surelog **956 databases / 1588 row-modes**: TOGOLD 144, AWAY 0, MOVED-WRONG 0 — only the four row-modes moved.  uhdm2rtlil **1358 databases**: the whole family is 14 cells and every one already agreed; 0 moved. |
| the grids (5 arms × 2 views, one fresh Surelog golden each) | **TOGOLD 32, AWAY 0, MOVED-WRONG 0.** |
| the WIDE boundary (4899 sources × 2 views × 2 binaries) | `LISTED=4899 FENCED_SKIPPED=0 PROCESSED=4899 MOVED=6 ASYMMETRIC=0`.  Four are this pass's own arms.  The other two are § 169's arms — the same wildcard-clone family — and **both move TOWARD golden**: `g169_b_forms.sv`'s official cmp log is byte-identical (58 lines, same head) with 8 cells TOGOLD, and `v169_g_control.sv` goes **33 cmp lines / 1 head → 0 lines / 0 heads, i.e. EQUAL to golden**. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine surelog sweep, which `ct8rows`
certified byte-identical to the committed baseline on every one of the 1588
rows:

```
SeqDriver      default         33      1
SeqDriver      testflags       33      1
MiniAmiq       default         33      1
MiniAmiq       testflags       33      1
```

which is the brief's R0 to the byte.  The pristine log
(`head_pris_SeqDriver.default.cmp`) reads:

```
LHS: <null>
RHS:
decompile:
constant: , id:367, line:368:36, endln:368:48
|vpiParent:
\_param_assign: , id:366, line:368:11, endln:368:48
|vpiDecompile:32'h04c11db6
|vpiSize:32
|HEX:04c11db6
…
```

`BaseClass.h`'s **SINGULAR** `SafeCompare` prints this shape — `LHS: <null>`
with a full RHS — when OUR value is present and golden's is not, so the object
the judge stopped on lives in OUR database and the scan runs from ours to
golden (`ct178own.cpp`'s MIRROR mode, r10uvm164's).  MiniAmiq's log is the same
object with `svaunit_pkg` where SeqDriver has `adpcm_pkg` in the constant's
`ref_typespec` name.

The site is uvm-1.2 `src/base/uvm_misc.svh`:

```systemverilog
parameter UVM_STR_CRC_POLYNOMIAL = 32'h04c11db6;          // 368
function int unsigned uvm_oneway_hash ( string string_in, int unsigned seed=0 );
  …
  for (int _byte=0; _byte < string_in.len(); _byte++) begin
     …
     for (int _bit=0; _bit < 8; _bit++) begin
        …
        if (msb ^ current_byte[_bit]) begin
           crc1 ^=  UVM_STR_CRC_POLYNOMIAL;               // 385:21
```

a free package function, the read three control levels deep.

---

## 2. THE JUDGE, DECODED — **THE PER-LISTING COPY MAP**

`ct178own.cpp`'s STEP 2 prints **every copy** of the reference, **per listing**,
on both sides.  The listing key is the design-level vector membership of the
copy's outermost package ancestor (`design::AllPackages` / `design::TopPackages`)
by **role and package NAME** — never an index or an object id, which are
producer-private.  SeqDriver (`OWNER.r10uvm178.SeqDriver.txt`):

```
  ---- GOLDEN ----
    ALL[1] uvm_pkg      | uvm_oneway_hash | 385:21 | BOUND -> constant()@368:36
    ALL[2] adpcm_pkg    | uvm_oneway_hash | 385:21 | BARE
    TOP[1] uvm_pkg      | uvm_oneway_hash | 385:21 | BOUND -> constant()@368:36
    TOP[2] adpcm_pkg    | uvm_oneway_hash | 385:21 | BARE
  ---- OURS ----
    ALL[1] uvm_pkg      | … | BOUND -> constant()@368:36 #367
    ALL[2] adpcm_pkg    | … | BOUND -> constant()@368:36 #367     <- the HOME's object!
    TOP[1] uvm_pkg      | … | BOUND -> constant()@368:36 #6299
    TOP[2] adpcm_pkg    | … | BOUND -> constant()@368:36 #181724
```

MiniAmiq is the same map with `svaunit_pkg` for `adpcm_pkg`.

> **THE BRIEF'S COUNT IS HALF THE TRUTH, AND WORTH CORRECTING.**  It says golden
> holds "two copies of `ref_obj`, one bound and one null".  Golden holds
> **FOUR**: the parameter's home package appears twice (the `AllPackages` and
> `TopPackages` listings) and **so does the wildcard importer**, which carries a
> `clone_tree` copy of the home's whole subroutine listing.  The split is not
> one-bound-one-null but **two bound (both HOME listings) and two bare (both
> IMPORTER listings)**, and we bound all four.  The law is therefore about the
> CLONE, not about the view — which is exactly why an ALL/TOP-keyed gate would
> have been wrong and a clone-keyed one is right.

Note also that our `ALL[2] adpcm_pkg` copy bound the **home listing's own**
constant `#367` — a cross-listing splice — which is why the head object the
judge named lives in `uvm_pkg`'s listing on SeqDriver while it lives in the
clone's own listing on MiniAmiq.  Both are the same defect.

---

## 3. SURELOG, DECODED — **THE LATE-BINDING LIST HOLDS POINTERS TO THE ORIGINALS, AND THE CLONE IS NOT ON IT**

The only site in Surelog that binds a package-parameter reference to the
`param_assign`'s **`Rhs`** — which is what golden's home copies hold — is
`UhdmWriter::lateBinding`, `src/DesignCompile/UhdmWriter.cpp:3814-3821`:

```cpp
    if (m && m->Param_assigns()) {
      bool isParam = false;
      for (auto p : *m->Param_assigns()) {
        const any* lhs = p->Lhs();
        if (lhs->VpiName() == name) {
          // Do not bind blindly here, let the uhdmelab do this correctly
          // Unless we are in a package
          if (m && m->UhdmType() == uhdmpackage) ref->Actual_group(p->Rhs());
```

and the loop it sits in is `UhdmWriter.cpp:3294-3297`:

```cpp
void UhdmWriter::lateBinding(Serializer& s, DesignComponent* mod, scope* m) {
  for (UHDM::ref_obj* ref : mod->getLateBinding()) {
    if (ref->Actual_group()) continue;
```

— it walks the **DesignComponent's own registration list**, a
`std::vector<UHDM::ref_obj*>` of the reference objects the compiler pushed while
compiling that component (`DesignComponent::needLateBinding`).

`CompileHelper::importPackage` does two separate things with the home package,
a hundred lines apart:

```cpp
    // Incomplete bindings                       CompileHelper.cpp:191-193
    for (auto& var : def->getLateBinding())
      scope->needLateBinding(var);               // <- the ORIGINAL pointers
…
          if (inPackage) {                       CompileHelper.cpp:319-325
            ElaboratorContext elaboratorContext(&s, false, /*mute errors*/ true);
            task_func* clone =
                (task_func*)UHDM::clone_tree((any*)func, &elaboratorContext);
            sfuncs->push_back(clone);            // <- a FRESH object graph
```

The list the importer inherits holds the **home's own** `ref_obj` pointers, not
the clones'.  So when `lateBinding(s, adpcm_pkg, p)` runs (`UhdmWriter.cpp:1304`)
it re-visits `uvm_pkg`'s objects — already bound, `continue` — and the CLONE's
`ref_obj`, a fresh object created by `clone_tree`, is on **no** list at all and
is never bound.  `ref_obj::DeepCopy`'s carry-over
(`if (!clone->Actual_group()) clone->Actual_group((any*)Actual_group());`,
`UHDM/build/generated/src/ref_obj.cpp:104-110`) copies nothing either, because
`lateBinding` lives in the **writer** and runs long after every import has been
compiled.  Both of the importer's listings therefore hold a bare reference, in
every database, forever.

That also explains the shape of the neighbouring family: **folds** (a parameter
replaced by its value) happen at COMPILE time under `Reduce::Yes` and ARE
inherited by the clone, while **bindings** happen in the writer and are not.
§ 169 already decoded the first half; this is the second.

---

## 4. SLANG, DECODED — THE BINDING SITE, AND THE GATE

Our binding site is `src/ExprEmit.cpp`, the arm reached when the resolved
symbol's own scope is a PACKAGE and the symbol is a PARAMETER:

```cpp
                // Package-function bodies keep a ref bound to the param's
                // def-view constant.
                if (currentTf && pkgScopeInst) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    auto pit2 = pkgParamDefRhs.find(&nv.symbol);
                    if (pkgEmitTopView && pit2 != pkgParamDefRhs.end())  …
```

The law is ONE gated suppress around that three-way bind — the reference keeps
its name, its full name, its parent and its span, and loses only `vpiActual`.
The gate has three terms and every one is measured on an arm:

1. **`pkgImportCloneEmit`** — the listing test, the same one § 169 uses for its
   fold window and § 9 uses for the enum-constant arm of this very code path.
   It names BOTH of the importer's listings, which is what the copy map asks
   for.
2. **the parameter's home IS the package whose listing was cloned.**  The
   clone's home is taken from `currentSubSym` — the HOME's own subroutine
   symbol, which a clone body re-walks — and NOT from `pkgImportCloneHomePkg`,
   which the class-method clone path deliberately leaves null and which feeds
   `pendingFuncRet`'s return-variable patching.  The walk finds the home package
   for **both** clone halves: a free subroutine's parent scope IS the package,
   and an out-of-body class method's is the class whose parent is the package.
   A clone body that reads a THIRD package's parameter has **no reference in
   golden at all** — the home's own compile already substituted the value, so
   the clone carries a `constant` (arm C `Renest178::wild_read178` reading
   `Src178::src_poly178`).  That cell is the FOLD family's residue and must not
   move.
3. **the reference is not an operand of the RETURN expression § 169/§ 30's
   `Reduce::Yes` window already owns** — `pkgRetTopExpr8` with an `operation` or
   `sys_func_call` parent.  The reduce descends into an operation's operands and
   into a SYSTEM call's arguments, and not into a USER call's.  Measured on nine
   written forms across two arms: golden holds a `constant` for
   `return a + stepB178`, `return kb169 + 1`, `return kb169 ? 2 : 3`,
   `return {sb169, sb169}` and `return $clog2(kb169)`, and a **bare `ref_obj`**
   for `return b_xor178(polyB178)` — which is one of this law's own TOGOLD
   cells.

Terms 2 and 3 exist **only** to stop the law touching cells golden has no
reference for.  Drop either and the grid reports MOVED-WRONG cells (this pass
built and measured both weaker gates before settling on this one); keep them and
the grid, the nine-row census and the whole-corpus census all read
**MOVED-WRONG 0**.

---

## 5. THE GRIDS — five arms, ten arm-views, one fresh Surelog golden each

`grid178.sh` builds the Surelog golden and BOTH binaries' databases in the DEF
and ELAB views, records every rc (an rc=139 segfault must never read as a
result) and echoes every command **with its binary path** into `cmds.txt`.
Arm names, numbers, case and declaration order are varied on purpose so that an
arm cannot agree by mirroring itself.

| arm | dimension it walks | cells |
|---|---|---|
| `g178_a_copy.sv` | **copies** — the home listing (×2) and ONE clone, then THREE more clones with unlike names (`Crc_one`, `Kalpha`, `kBeta`, `K3`) | 8 TOGOLD |
| `g178_b_pos.sv` | **reference positions** — xor-assign / if-condition / call argument / return / binary operand, each at home and in a clone | 6 TOGOLD |
| `g178_c_home.sv` | **parameter homes** — own / wildcard-imported / explicitly imported / `::`-scoped / a clone CARRIER's own parameter / a module function | 0 moved — every cell here is one the gate refuses |
| `g178_d_depth.sv` | **control depth 0…4** (`r ^= P`, `if`, `for`+`if`, `for`+`for`+`if`+`begin` — the uvm shape — `while`+`case`+`for`) plus a class method | 10 TOGOLD |
| `g178_e_oob.sv` | **the OUT-OF-BODY class method inside the clone** — the other half of `getTask_funcs()`, which is 34 of the corpus's 36 face cells per row-mode; an IN-BODY method is never cloned | 8 TOGOLD, **and the arm's whole PREF family is then EXACTLY golden's** |

```
ROW-MODE                      GOLD    PRIS   PATCH  TOGOLD    AWAY MVWRONG STILLWR
a_copy.def                      10      18      18       8       0       0       8
a_copy.elab                     20      36      36       0       0       0       8
b_pos.def                       14      26      26       6       0       0      12
b_pos.elab                      28     124     124       0       0       0      48
c_home.def                       4      12      12       0       0       0       8
c_home.elab                      8      24      24       0       0       0       8
d_depth.def                     21      31      31      10       0       0      10
d_depth.elab                    47      67      67       0       0       0      10
e_oob.def                       17      17      17       8       0       0       0
e_oob.elab                      34     110     110       0       0       0      38
TOTAL                          203     465     465      32       0       0       —
```

**The ELAB view is a different world and this law never enters it**: under
`-elabuhdm` golden binds every one of these references to the `parameter` object
through the UHDM elaborator's own `bindAny`, and PRIS == PATCH in every elab row
above (0 moved).  The corpus databases are the DEF-shaped invocation, which is
why the arm-A DEF head is the corpus head to the byte.

---

## 6. THE CENSUS

`ct178cen.cpp` reads `Serializer::AllObjects()` — never dump TEXT — and prints
three families; the DEF/ELAB RUN is deliberately NOT part of any key (RESUME.md
§9: the two producers label the run differently), while the WITHIN-DATABASE
LISTING is keyed, by role and name.  `score178.py` joins them as MULTISETS.
Golden-vs-golden is the calibration: every key that exists on both sides with
the same multiset scores STILL-OK and is not printed.

Nine UVM row-modes, all three families:

```
PREF   GOLD 1800  PRIS 1792  PATCH 1792   TOGOLD 144  AWAY 0  MVWRONG 0
REF    GOLD 539488 PRIS 539374 PATCH 539374 TOGOLD 72  AWAY 0  MVWRONG 0
OBJ    GOLD 812   PRIS 810   PATCH 810      TOGOLD 0   AWAY 0  MVWRONG 0
```

The 144 PREF cells are 36 per moving row-mode — 18 source cells × 2 listings —
and they are **exactly the set predicted from the pristine databases before the
patch was built**: `uvm_oneway_hash`'s `UVM_STR_CRC_POLYNOMIAL`, ten
`uvm_object::*` / `uvm_component::apply_config_settings` /
`uvm_packer::pack_object` reads of `UVM_COPY` / `UVM_COMPARE` / `UVM_PRINT` /
`UVM_RECORD` / `UVM_SETINT` / `UVM_SETOBJ` / `UVM_SETSTR` / `UVM_PACK` /
`UVM_UNPACK` / `UVM_CHECK_FIELDS`, and the five `uvm_root::report_header`
copyright strings.  The REF family — **every** reference in the database —
moves the same cells and no others (72 = 18 per row-mode; that key does not
carry the listing, so the two listings' copies collapse into one multiset).

Whole corpus, PREF:

```
surelog     956 databases / 1588 row-modes   TOGOLD 144  AWAY 0  MVWRONG 0
uhdm2rtlil 1358 databases                    the family is 14 cells; 0 moved
```

Only SeqDriver ×2 and MiniAmiq ×2 moved a single cell on either corpus.

---

## 7. THE MOVERS, PREDICTED BY NAME FIRST

`predict178.py` ran on the **pristine** census only, before the patched sweep,
and named the four row-modes and their 36 cells each
(`PREDICT.r10uvm178.surelog.txt`); it named **zero** on uhdm2rtlil
(`PREDICT.r10uvm178.uhdm2rtlil.txt`).  `byteverify.sh SELFCHECK=1` then measured
**4 / 956** and **0 / 1358**, and the four are those four.  The whole-dump
order-blind diff of each mover is **72 lines, all removals, 0 additions**
(`MOVERS.r10uvm178.txt`).

The documented Scoreboard/default COIN did not flip in this pass's sweeps: its
database is byte-identical between the two binaries.

---

## 8. THE NEW HEAD — R0 FOR THE NEXT PASS

Both moving rows land on the **same** new head, and it is a different object and
a different family (`OWNER.next.r10uvm178.txt`, `head_pat_*.cmp`):

```
design::Compare r=-14
HEAD LHS(golden) = logic_typespec(uvm_bitstream_t)@49:9-49:42
HEAD RHS(ours)   = logic_typespec(uvm_pkg::uvm_bitstream_t)@49:9-49:42
```

`logic_typespec::Compare` reaches `VpiName` and the names differ: **golden's
copy of the typespec inside the wildcard-import clone is named BARE
(`uvm_bitstream_t`) and ours keeps the home qualifier (`uvm_pkg::…`)**.  The
site is uvm-1.2 `base/uvm_object_globals.svh:49`
(`typedef logic signed [4095:0] uvm_bitstream_t;`) reached through
`uvm_bitstream_to_string`'s local `_t`, and golden's `ref_typespec` above it is
named for the IMPORTER (`adpcm_pkg::uvm_bitstream_to_string::_t::uvm_bitstream_t`
on SeqDriver, `svaunit_pkg::…` on MiniAmiq) while its `vpiInstance` still points
at the home `uvm_pkg`.  A cmp line count going UP with a CHANGED head object is
the expected shape (RESUME §7): 142 and 116 are the new head's decompile size.

The mirror scan also shows the second half of that head: our `ALL[1] uvm_pkg`
package carries **46** `Typespecs` where golden's `TOP[1]` carries **89** and its
`ALL[1]` carries 46 — i.e. the judge is pairing listings, so the next pass wants
`ct178own.cpp`'s listing-aware copy map from the first minute.

---

## 9. RESIDUES

- **R0** — the new head above: a wildcard-import clone's cloned TYPESPEC is
  named with the HOME's qualifier by us and BARE by golden.  SeqDriver ×2 (142
  cmp lines) and MiniAmiq ×2 (116), one head each, one object family, both rows
  the same law.  The listing-aware copy map (`ct178own.cpp`, STEP 2) and the
  per-listing census (`ct178cen.cpp`) are the instruments; start from
  `OWNER.next.r10uvm178.txt`.
- **R1** — 14 PREF cells per moving row-mode are still STILL-WRONG after this
  law and every one has the same shape: golden holds no reference at all where
  we hold a `ref_obj`.  They are the FOLD family's (§ 169 / § 30 /
  § fcArgPkgParamValueFolds32), not this one's, and the gate's terms 2 and 3
  exist to leave them exactly where they were.
- **R2** — the ELAB (`-elabuhdm`) world binds these references to the
  `parameter` object on golden's side in every listing, home and clone alike;
  our elab databases already agree cell-for-cell on the arms that this law
  touches, and the law never fires there.  A pass that widens into the elab
  world must re-measure that first.
- **R3** — `tools/probe/r10buvm22repro/g22.sv` holds a **build-layout-derived
  integer** in an associative-array typespec range bound where golden holds
  `constant STRING:associative`: deterministic per binary, shifting by exactly
  one page when the binary grows, and therefore a false mover in any wide
  boundary run.  It is an uninitialised-read residue of the array-typespec
  family, invisible to the judge (the arm's cmp log is byte-identical at 3438
  lines / 1 head on both binaries), and it is worth fixing simply so that the
  boundary gate stops lying.

---

## 10. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct178own.cpp` | the owner-finder, MIRROR form (r10uvm164's) **plus the PER-LISTING COPY MAP** — every copy of a named reference, per listing, both sides, with its binding |
| `ct178cen.cpp` | the census: `PREF` (the law's family, keyed by listing × copy × home × span), `REF` (every reference — the must-not-move family), `OBJ` (kind counts) |
| `cen178.sh` | runs the census over a `verify_golden` workdir, reading each golden path out of that directory's OWN `cmds.txt` |
| `score178.py` | the multiset join and the TOGOLD / AWAY / MOVED-WRONG / STILL-WRONG scoring; strips the producer's own tag field from the key |
| `predict178.py` | the mover prediction from PRISTINE databases only |
| `grid178.sh` | the arm driver (golden + both binaries, DEF and ELAB, every rc recorded) |
| `bound178.sh` | the WIDE boundary gate (fd-3 list, children `</dev/null`, PROCESSED asserted, recursive) |
| `g178_{a_copy,b_pos,c_home,d_depth,e_oob}.sv` | the five arms |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the standard gates, reused verbatim |
| `OWNER.*` `PREDICT.*` `GRID.*` `CENSUS.*` `MOVERS.*` `BOUNDARY.*` `GATES.*` | the transcripts every number above came from |
| `head_pris_*.cmp` `head_pat_*.cmp` | the official cmp logs of the four moving row-modes, before and after |
