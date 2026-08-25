# r10v144 — ADVERSARIAL VERIFICATION of r10uvm144, and the two fixes it needed

**VERDICT: ACCEPT-WITH-FIX.** Ship `/tmp/r10uvm144.verified.patch`.

r10uvm144's decoded model is right, its head measurement is right, and every
headline number in its report reproduces here **bit-for-bit** — including both
binary md5s, the 174-line BuildUVMPkg head, the 2-line order-blind mover
attribution and the 13-arm boundary mover set. But the pass as shipped
introduces **two regression classes on legal SystemVerilog**, twelve cells over
five of my arms, all of them PRISTINE-RIGHT → SHIPPED-WRONG. Both are fixed
here, both fixes are **corpus-invisible** (0 byte movers over all 2314
databases against the shipped binary), and the fix additionally clears a
four-cell standing residue on § `collArgNamedBlkLocalNoBind15`'s own arm.

---

## 1. WHAT REPRODUCED, EXACTLY

Built both binaries myself in fresh worktrees at 9d72d85, `-j 2`, md5 taken
separately, frozen `chmod 555` before any sweep:

| | md5 | claimed |
|---|---|---|
| PRISTINE | `bc675fd7475d665c01c59756784f3347` | same |
| SHIPPED  | `cc9000b97d76de1b0400d6356d337f23` | same |

* goldens **23/0** on all three binaries; `/bin/false` **0/23**.
* `cmds.txt` audited by BINARY PATH in every workdir: 2981 slang invocations
  each, **all** naming the intended frozen binary, **0** naming anything else.
* status histograms identical to the report (471/283/25/10/5, 466/…,
  679/50/2 both u2r modes).
* `ct8rows` **PASS** on both corpora against the committed baselines and
  against my own pristine control — **NO ROW CONVERTED**, `results/*.csv` only
  READ.
* `byteverify SELFCHECK=1`: u2r **0/1358**; surelog **3/956** —
  `BuildUVMPkg` ×2 (predicted, and the order-blind attribution is the
  implementer's two added lines / zero removed, character for character) plus
  `Scoreboard/default`, whose sorted path-normalised dump diff against pristine
  is **ZERO LINES**: the ~50/50 `vpiTaskFunc`-order COIN, which flipped in my
  run and not in theirs.
* heads: SeqDriver 6254, SimpleUVM 29, Scoreboard/default 29, MiniAmiq 6222,
  Earlgrey 110/142, Rggen 0 — unchanged; **BuildUVMPkg 55 → 174 both modes**,
  one head per run. My `BuildUVMPkg.default.cmp` is byte-identical to their
  archived `head_pat_BuildUVMPkg.default.cmp`, so R0 is confirmed as written.
* wide boundary gate, whole probe tree: their nine movers, arm for arm, with
  `r10uvm28repro/t38a/dut.sv` NOT moving. `g32a3` and `v2_ctx` re-measured
  against golden: **TO-GOLDEN, 0 away**. `g22.sv`'s `uhdm-cmp` output
  byte-identical, R3 confirmed at `src/TypeEmit.cpp:10771`.

The **REFUTED brief framing** and the **`ref_obj::Actual_group` singular-overload
head decode** are both correct as written.

---

## 2. FINDING 1 (REGRESSION) — a NAMED block's local at control depth 0

**§ `namedBlkLocalNeverBindsInBodyWindow144v`.**

`CompileHelper::bindVariable` (`Surelog/src/DesignCompile/CompileStmt.cpp:3089`)
switches on the scope object's `UhdmType()` and has cases for `uhdmfunction`,
`uhdmtask`, `uhdmbegin` and `uhdmmodule_inst` — and **no case for
`uhdmnamed_begin`**. A local declared in a `begin : name` (a named `fork` arm
included) is therefore never searched for and the reference stays BARE, at ANY
control-body depth.

§ `blockLocalSameCtrlDepthArgBinds57` already carries that half of the law, but
it is only ever ASKED through `blkLocalWindowBind64` — i.e. as a way of LIFTING
§ `controlBodyNoBind28`, which is not asked at control depth 0. r10uvm144's arm
C cell `c12` writes its named block **inside an `if` body**
(`g144_c.sv:45`), so § 28 silenced that cell for a different reason and the gap
stayed invisible. Opening this arm's window then bound the depth-0 cells.

MEASURED, one golden per arm, DEF view (ELAB agrees with golden on both
binaries — Surelog late-binds there and so do we):

| cell | written | golden | PRISTINE | SHIPPED | VERIFIED |
|---|---|---|---|---|---|
| `v144_d_named.sv:18` d01 | in-body class FUNCTION, `begin : nb01 int y; B::si(y);` | bare | bare | **bound** | bare |
| `:35` d09 | the same in a class TASK | bare | bare | **bound** | bare |
| `:39` d11 | a NAMED block inside an UNNAMED one | bare | bare | **bound** | bare |
| `:43` d13 | a NAMED `fork` arm | bare | bare | **bound** | bare |
| `:54` d16 | a MODULE class's in-body method | bare | bare | **bound** | bare |
| `v144_a_homes.sv:37` a07 | the same shape, a seventh home | bare | bare | **bound** | bare |
| `v144_e_inst.sv:19`, `:40` e05 + the 3-instance child | the same shape | bare | bare | **bound** | bare |
| `:22` d03 | the UNNAMED twin at depth 0 | **bound** | bare | bound | bound |
| `:37` d10 | an UNNAMED block INSIDE a named one | **bound** | bare | bound | bound |
| `:41` d12 | the SUBROUTINE local read from inside a named block | **bound** | bare | bound | bound |
| `:26` d05 | r10uvm144's own `c12` shape (named block in an `if`) | bare | bare | bare | bare |
| `:29` d06 OOB, `:31/:33` d07/d08 package free fn, `:50/:52` d14/d15 module fn | | **bound** | bound | bound | bound |
| `:20` d02 | the RECEIVER-LESS twin of d01 | bare | **bound** | **bound** | bare |

d03 / d10 / d12 are what keep this from becoming "a block local never binds";
d06 / d07 / d08 / d14 / d15 are what keep the gate at § 12's own
`curSubClassScope9 && !curSubOob9`; d02 is a PRISTINE-wrong cell the term also
corrects.

**The fix** (`src/ExprEmit.cpp`, one term, one disjunct):

```c++
bool namedBlkLocalNoBind144v = false;
if (curSubClassScope9 && !curSubOob9 && classArgBindDepth12 > 0 &&
    nv.symbol.kind == SymbolKind::Variable) {
    if (auto* nbs144v = nv.symbol.getParentScope()) {
        auto& nbd144v = nbs144v->asSymbol();
        namedBlkLocalNoBind144v = nbd144v.kind == SymbolKind::StatementBlock &&
                                  !nbd144v.name.empty();
    }
}
```

`classArgBindDepth12 > 0` keeps the term inert everywhere a window is not open,
so no position outside a call-argument window changes at all.

---

## 3. FINDING 2 (REGRESSION) — `int a, b;` is ONE grammar element

**§ `ctorEatenElementIsTheWholeDeclaration144v`.**

§ `constructorBodyElementShift27` eats the first **GRAMMAR** element, and
`int a, b;` is ONE `block_item_declaration` carrying TWO declarators. slang's
statement list carries TWO `VariableDeclStatement`s, so r10uvm144's
index-keyed recorder (`i < from || i >= to`) silences only the FIRST declarator
and the SECOND one binds through the window the same pass opened.

| cell | written | golden | PRISTINE | SHIPPED | VERIFIED |
|---|---|---|---|---|---|
| `v144_b_ctor.sv:32` b01 | `function new(); int b01a, b01b; B::si(b01a); B::si(b01b);` | both bare | both bare | `b01b` **bound** | both bare |
| `:77` b25 | `int b25a = 3, b25b = b25a;` — the initialised twin | bare | bare | **bound** | bare |
| `:34` b02 | `int b02a; int b02b;` — TWO declarations | `b02b` **bound** | bare | bound | bound |
| `:61` b18 | a ctor WITH a port list | bound | bare | bound | bound |

b02 is the control that keeps this from becoming "every declarator of the
constructor". Both cells regress in **both views**.

**The fix** (`src/StmtEmit.cpp`, in `emitCtorBody27`): key the record on the
DECLARATION SYNTAX NODE the walk did not reach (the declarator's `parent`, i.e.
the whole `data_declaration`) and record every declarator of that node whatever
its statement index.

---

## 4. WHAT THE FIXES COST, MEASURED

* **Corpus: nothing.** `byteverify SELFCHECK=1`, VERIFIED vs SHIPPED:
  **MOVERS 0 / 1358** (uhdm2rtlil) and **0 / 956** (surelog),
  `PATH_SETS_IDENTICAL` on both, SELFCHECK 1357/1358 and 955/956.
  `BuildUVMPkg` is `72243e358ecb` in both modes on BOTH binaries. All seven
  head files byte-identical. `ct8rows` PASS on both corpora against the
  committed baselines and my own pristine control. **NO ROW CONVERTED.**
* **Boundary, SHIPPED vs VERIFIED, 4121 arms:** `MOVED_ARMS=5 RC_DIFFS=0` —
  four are my own arms (positive control) and the fifth is
  `r10buvm15repro/v5_named15.sv`, § `collArgNamedBlkLocalNoBind15`'s own
  verifier arm, whose FOUR standing wrong cells per view (named-block locals
  through an ORDINARY call: `sink(nloc)`, `hh.one(nloc)`, `sink(sink2(nloc))`,
  `sink(n2loc)`) go to **ZERO**, AWAY-LOST=0 AWAY-ADDED=0.
* **My arms, VERIFIED, both views: REGRESS-LOST=0 REGRESS-ADDED=0 on all five.**
  `v144_c_faces` and `v144_d_named` and `v144_e_inst` reach golden EXACTLY
  (0 missing, 0 extra) in the DEF view.
* Gates: goldens 23/0, `/bin/false` 0/23, canaries `ok=52`/`ok=8` changed=0,
  ctcan2 PASS both, canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0` in BOTH
  probe directories, SVSwitch `4842211c4030` and YosysVerx `6ccda350c24a` held,
  InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical.

---

## 5. THE GRIDS I BUILT (`ARMS.r10v144.txt`)

| arm | grid |
|---|---|
| `v144_a_homes.sv` | the WINDOW over HOMES the implementer's arm C did not spell: in-body function / in-body task / out-of-body / package free / static method / unnamed block / **named block** / fork arm / one control deeper / expression position / class property / formal / forward-declared handle / queue / operation argument / receiver-less control / nested scoped call, then MODULE function, MODULE task, MODULE `initial`, MODULE class, INTERFACE function, INTERFACE class, PROGRAM function, PROGRAM `initial`, `$unit` function, `$unit` class |
| `v144_b_ctor.sv` | the FENCE taken apart: **two declarators in one declaration**, two declarations, `super.new()` first, an assignment first, static local, automatic local, queue / dynamic / associative / fixed / string / forward-declared class / typedef'd class / parameterized specialization / enum / packed struct as the first body element, a decl inside an explicit `begin`, a ctor WITH ports, the inc/dec operand, the if-condition, the assignment RHS, an OUT-OF-BODY constructor, the ordinary-method twin, the receiver-less call, an initialiser that reads its own sibling declarator, § 71's and § 141's must-stay stubs, a `super.new(1)` derived ctor, and the module / interface / `$unit` homes |
| `v144_c_faces.sv` | the brief's FACE × SITE grid in ORDINARY methods, including the three declaration objects that come out as a `ref_var` (a class TYPEDEF compiled late, `semaphore`, `process`) which `refVarLocalNoBind5` governs and which the window ALSO flips |
| `v144_d_named.sv` | the named-block law at control depth 0, sixteen cells, scoped and receiver-less, in-body / out-of-body / package / module |
| `v144_e_inst.sv` | reachability, INSTANCE COUNT (1 and 3), SPECIALIZATION COUNT (2), and the cross-class leakage test for `ctorUnlistedBid144` (eight classes reusing the SAME local names, half behind an eaten first element) |

**Interface class** is not in the grid because SystemVerilog interface classes
carry only pure virtual prototypes: there is no body and no body local to bind.

---

## 6. RANKED RESIDUES (measured, NOT fixed here)

1. **R3, `src/TypeEmit.cpp:10771` — an UNCHECKED DOWNCAST.**
   `auto& fua = ct.as<FixedSizeUnpackedArrayType>();` with no kind test, reached
   for an ASSOCIATIVE typedef through the elaborated clone path; `fua.range` at
   `:10855` then prints whatever an `AssociativeArrayType` holds at that offset.
   CONFIRMED independently: `r10buvm22repro/g22.sv`'s whole-dump delta between
   pristine and shipped is exactly three such numbers, and `uhdm-cmp`'s output
   is byte-identical. It is PRE-EXISTING at 9d72d85 and corpus-invisible today,
   but it is a *build-sensitive* read: any future edit can change what it
   prints, and the wide boundary gate will keep reporting the arm as a mover
   until it is kind-tested. **Highest-value cleanup on this list.**
2. **The ctor fence does not survive `§ incDecOperandBind21`.**
   `v144_b_ctor.sv:63` b19 `function new(); int b19x; b19x++; B::si(b19x);` —
   the eaten local is golden-BARE and both binaries bind it, because
   `incDecOperandBind21` is a `&&`-override outside the disjunction.
   PRE-EXISTING (pristine binds it too), so not a regression; one more disjunct
   would close it, and it wants its own golden grid first.
3. **The eaten declaration's own initialiser is still emitted.**
   `v144_b_ctor.sv:77` b25 — golden has NO `ref_obj` at 77:58 at all; we emit a
   bare one. That is § 27's element arithmetic, not this law.
4. **The INTERFACE and PROGRAM homes lose whole cells in the DEF view.**
   `v144_a_homes.sv:81/82` (an interface function and an interface class) and
   `:99` (`$unit` class) are golden-BOUND rows we do not produce at all, and
   `:93` (a program `initial`) binds a `logic_net` where golden binds nothing.
   `v144_b_ctor.sv:94` is the same interface-class gap. All PRE-EXISTING and
   untouched by this pass.
5. **R2 (the implementer's) — the escaped-`\new` reference COLUMN**, 33:72 vs
   golden 33:76, pre-existing and corpus-invisible. Confirmed.
6. **R0 stands as written**: the `hier_path` element shape at
   `uvm_pkg.sv:76967`, `rw.value[idx][8 * i +: 8]` — golden a `var_select`
   named `value` with two `vpiIndex` children, ours a flat
   `indexed_part_select` named `value[idx]`. My head file is byte-identical to
   theirs.

---

## 7. FILES

| file | what it is |
|---|---|
| `v144arm.sh` | build one arm: Surelog golden in BOTH views + both frozen binaries + official `uhdm-cmp`; every child rc printed |
| `v144scan.py` | the WHOLE-DUMP `ref_obj` binding census — every ref_obj, not only a call's direct argument, keyed on `vpiName` + `line:col` + the ACTUAL's UHDM kind and name. No fullname, no id |
| `v144score.sh` | golden / pristine / patched scoring of one arm dir, both views, plus the pristine-vs-patched delta |
| `pred144v.py` | the a-priori mover predictor for the two verifier fixes, read off PRISTINE dumps |
| `bound144v.sh` | the wide boundary gate (r10uvm144's, banner aside) |
| `v144_a_homes.sv` … `v144_e_inst.sv` | the five grids |
| `ARMS/GATES/BOUNDARY.r10v144.txt` | the measurements above |
| `byteverify.sh ct8rows.sh canaries.sh ctcan2.sh canaudit.sh rowheads.sh` | the gate scripts, carried so this directory runs standalone |
