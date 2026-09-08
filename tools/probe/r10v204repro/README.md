# r10v204 — ADVERSARIAL VERIFICATION of r10uvm204 § `cloneForInitVarBind204`

**Verdict: ACCEPT-WITH-FIX.** Every headline number in the implementer's report
reproduced bit-for-bit from binaries this verifier built itself, including both
binary md5s, both pristine head files, the a-priori prediction and the 154-line
mover attribution. Six new adversarial arms then found **one** face the
implementer's five arms never reached, and on it the patch is
**pristine-right → patched-wrong on legal SystemVerilog**: a `for` loop whose
init variable is declared through a **typedef alias**. The fix is four lines in
the same probe (`src/UhdmExporter.cpp`), gated by the same clone gate, and it
also makes the implementer's own arm A strictly better (def `TO-GOLDEN` 2 → 8).

**MEASUREMENT-ONLY probes.** The official `uhdm-cmp`
(`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py` are the
authorities. slang was **NOT** patched; `results/*.csv` were **READ ONLY** and
**NOT EDITED**; **NO CORPUS ROW WAS CONVERTED**; `GOLDEN_DEFER` stayed unset.
The four slang-fenced tests were never dispatched by anything here and are named
in no file in this directory.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `a4b4caa8` |
| pristine binary | built by this verifier from its own clean `a4b4caa8` worktree, md5 `c086973114a864cf56a951af381599db` — **byte-identical to the implementer's pristine AND to the main tree's `build/slang-uhdm`** |
| implementer's patched binary | rebuilt by this verifier from `/tmp/r10uvm204.patch`, md5 `ffc12515dbb721aaba8405a22c4155e2` — **byte-identical to the implementer's** |
| verified binary | `505cad23a156a75a6da1a3fd69b64617` (implementer's patch + this pass's four-line fence) |
| production surface | `src/UhdmExporter.cpp` ONLY, in both patches |

---

## 1. REPRODUCTION — every headline number, re-measured

Built both binaries in fresh worktrees at `a4b4caa8`, froze them `chmod 555`,
exported `SLANG_UHDM` explicitly per binary and audited **every** `cmds.txt` by
binary PATH (1458 of 1462 uhdm2rtlil files name the frozen binary, the other 4
name no binary at all — the two `SURELOG_FAIL` rows in both modes; **0 files
name any other binary**).

| claim | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `c086973114a864cf56a951af381599db` | **same** |
| patched binary md5 | `ffc12515dbb721aaba8405a22c4155e2` | **same** |
| goldens, pristine / patched | 23 PASS / 0 FAIL | **same, both**; `/bin/false` **23 FAIL** |
| uhdm2rtlil, both modes, both binaries | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL | **same** |
| `ct8rows` uhdm2rtlil, patched vs committed baseline and vs own pristine | 0 differing rows | **PASS on all three comparisons** |
| `byteverify` uhdm2rtlil | MOVERS 0 / 1358, SELFCHECK 1357/1358 | **same** |
| surelog sweep, 1588 rows | tallies unchanged | **same** (`default` 472 EQ / 9 NE, `testflags` 468 EQ / 7 NE, both binaries) |
| `ct8rows` surelog, patched vs own pristine | 0 differing rows | **PASS** |
| `ct8rows` surelog, vs committed baseline | exactly one DUMP-COLUMN cell, `Earlgrey_0_1,testflags` `CMP_EQUAL,,,differ` → `CMP_EQUAL,,,`, and the PRISTINE sweep shows it too | **confirmed independently: this verifier's OWN pristine sweep produces the identical cell.** Status stays `CMP_EQUAL`; no row converted |
| `byteverify` surelog, patched vs pristine | MOVERS 5/956 = the four predicted + the Scoreboard coin | **MOVERS 4/956 — exactly the four predicted by name; the coin did not flip on this run.** Consistent with the coin law either way |
| a-priori prediction from pristine databases alone | `scanned=948 NODB=617 FENCED=8`; `strict>0` on exactly SeqDriver ×2 and MiniAmiq ×2, `strict=12` each | **identical, line for line, including every `wide=` figure** |
| mover attribution, each of the four law rows | PLAIN == ORDER-BLIND == 154; `vpiActual` 12 added / 0 removed; `class_var` 76 added / 64 removed; 0 `class_var` lines not naming `::cb`; 2 non-law lines | **identical on all four rows** |
| rowheads, pristine | SeqDriver ×2 and MiniAmiq ×2 **29 / 1**; SimpleUVM ×2 1327654; Scoreboard/default 95; BuildUVMPkg ×2 **0/0**; Earlgrey 386 / **0/0**; Rggen/default **0/0**; Scoreboard/tf + Rggen/tf `SKIP-NOFILE` | **identical** |
| rowheads, patched | the four go **29 → 112**, one head, everything else unchanged | **identical** |
| the head files | `head_pris_*.cmp` and `head_pat_*.cmp` | **all eight byte-identical to this verifier's own** |
| the 491 for-loop census | golden and ours agree kind for kind (class_var 122 / int_var 306 / bit_var 8 / ref_var 55), every one `notlisted` | **identical, both sides, `FOR_STMTS=491 INIT_STMTS=491`** |

**The decode was checked against the source, not taken on trust.**
`~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp` `compileForLoop`
(`:2822`) reads exactly as quoted: the `paFor_variable_declaration` branch
compiles `compileVariable(…, Data_type, …)`, does `assign_stmt->Lhs(var)` and
puts the variable nowhere else, and its `while` walks *sibling declarations*, so
`for (int a = 0, b = 1; …)` — one node, two declarators — really does give
golden ONE init assignment (residue R2, confirmed on a real golden below).

**Where the implementer's own numbers do NOT reproduce: nowhere.** The one
difference is the Scoreboard/default coin, which landed on the other face in
this verifier's run; that is the documented ~50/50 and it is order-blind clean.

---

## 2. THE DEFECT — a typedef-alias loop variable

`arms204v/v204_n_nested.sv` writes the six init forms again, but every loop is
**inside a nested `begin` block** of an out-of-body class method in a
wildcard-imported package. That matters: the implementer's arm A puts all seven
of its loops at the subroutine's own statement level, where our emitter's
`netMap` already registered the loop variable, so the *minting* case — the case
in which the new probe actually creates a binding — was never exercised for any
form except the class-typed one (arm E) and the block-nested class-typed one
(arm B). `v204_t_alias.sv` then surveys which declared KINDS golden binds.

One REAL Surelog golden decides. In the clone listing (`pkglist:sluicev204`):

| written form | our Lhs (and golden's) | golden binds the body reference? | pristine | implementer's patched |
|---|---|---|---|---|
| `for (Leaf c = …)` class | `class_var` | **YES** | `<null>` | BOUND ✔ TO-GOLDEN |
| `for (string s = …)` | `string_var` | **YES** | `<null>` | BOUND ✔ TO-GOLDEN |
| `for (int i = 0; …)` | `int_var` | YES | already bound | unchanged |
| `for (MyStruct s = …)` | `struct_var` | YES | `<null>` | BOUND ✔ |
| `for (logic [7:0] v = …)` typedef'd | `logic_var` | YES | already bound | unchanged |
| **`for (AliasLeaf c = …)` typedef alias** | **`ref_var`** | **NO — `<null>` everywhere** | **`<null>` ✔** | **BOUND ✘ AWAY-GOLDEN** |
| `for (pa = 0; …)` plain assignment | `ref_var`, no typespec | binds the REAL declaration | correct | unchanged (the fence holds) |
| `int a = 0, b = 1` second declarator | `int_var` | NO | already bound (pre-existing) | unchanged |

Golden leaves an alias loop variable's references unresolved in **every** view —
the `class_defn` view, the home package listing, the wildcard-import clone
listing and the elaborated module view — and `ref_obj::Compare` reads
`Actual_group`, so this is a field the judge reads.

Scores from `grid204.sh` (golden vs pristine vs the implementer's patched):

```
v204_n_nested  def   TO-GOLDEN 4   AWAY-GOLDEN 6   MOVED-WRONG 0
               elab  TO-GOLDEN 0   AWAY-GOLDEN 11  MOVED-WRONG 1
v204_t_alias   def   TO-GOLDEN 9   AWAY-GOLDEN 7   MOVED-WRONG 1
               elab  TO-GOLDEN 3   AWAY-GOLDEN 11  MOVED-WRONG 1
```

Golden-vs-golden calibration on every arm in every view: all mover columns 0.
Every AWAY-GOLDEN key names the alias variable and nothing else, e.g.

```
AWAY-GOLDEN AGALL|pkglist:sluicev204|ref_obj|cN2v204|40:9|/for_stmt:/begin:/begin:/function:Aditv204::winzev204/package:sluicev204
    golden={'<null>': 2}   pris={'<null>': 2}   pat={'BOUND ref_var cN2v204 FORINITVAR-DECL': 2}
```

(The single `MOVED-WRONG` on `v204_t_alias` is not the alias: it is
`sS204@46:53`, our `ref_obj` for `s.a++`'s operand, which golden writes at
column **59**. The census key carries the column, so a pre-existing span residue
reads as a moved key; the BOUND VALUE matches golden's. It survives the fix and
is reported as a residue, not a defect.)

---

## 3. THE FIX — four lines, same probe, same gate

```
§ cloneForInitVarBind204, the DECLARATION form's own fence
    A `for` loop variable written through a TYPEDEF ALIAS is a `ref_var` on both
    sides (§ aliasClassRefVar10) whose own `Actual_group` is null, and golden
    binds NOTHING to it — not the condition, not the increment, not the body, in
    no view.  The probe still MATCHES it, so the climb stops at the loop that
    declares the name (which is what keeps the init assignment's own `ref_var`
    Lhs off the subroutine-level name map and out of the self-cycle the pristine
    binary had), but it hands back NO TARGET and the reference stays bare.
```

`forInitVar204` now returns `const UHDM::variables*` instead of `UHDM::any*`,
and the call site binds only when the matched variable is not a `ref_var` (and
is not the reference itself). Nothing else changed; the plain-assignment fence,
the innermost-out climb, the shadowing order and the clone gate are untouched.

Result, same arms, golden vs pristine vs **verified**:

```
v204_n_nested  def   TO-GOLDEN 4   AWAY-GOLDEN 0   MOVED-WRONG 0
               elab  TO-GOLDEN 0   AWAY-GOLDEN 0   MOVED-WRONG 0
v204_t_alias   def   TO-GOLDEN 9   AWAY-GOLDEN 0   MOVED-WRONG 1   (the column residue)
               elab  TO-GOLDEN 3   AWAY-GOLDEN 0   MOVED-WRONG 0
```

and on the implementer's OWN five arms the fix is strictly better or equal:

| arm | implementer's patched | verified |
|---|---|---|
| `g204_a_forms` def | TO-GOLDEN 2, AWAY 0 | **TO-GOLDEN 8**, AWAY 0 |
| `g204_a_forms` elab | TO-GOLDEN 4, AWAY 0 | **TO-GOLDEN 15**, AWAY 0, MOVED-WRONG 1 † |
| `g204_b_ctx` | TO-GOLDEN 2 def, byte-identical elab | identical |
| `g204_c_shadow` | `CMP_EQUAL` both views, TO-GOLDEN 4 def | identical |
| `g204_d_noimport` | BYTE-IDENTICAL both views | identical |
| `g204_e_head` | 29 / 1 head → `CMP_EQUAL` 0/0 | identical |

† the one elab `MOVED-WRONG` is the alias key itself: golden `{<null>: 4}`,
pristine `{BOUND ref_var: 7}`, verified `{<null>: 7}`. The VALUE is now golden's;
only the multiplicity differs, and that 7-vs-4 clone-count difference is
pre-existing (pristine reads 7 too).

---

## 4. THE OTHER FACES — broken and unbroken

Four more arms, each through the same driver, one real Surelog golden per arm,
both views, both binaries. All of them behave **identically** on the
implementer's patched binary and on the verified one.

| arm | what it breaks | pristine → patched/verified |
|---|---|---|
| `v204_s_shadow` | for-in-for redeclaring the outer name, SIBLING loops sharing a name, foreach INSIDE for, for INSIDE foreach — all in a nested block | 29 cmp lines / 1 head → **`CMP_EQUAL` 0/0**; TO-GOLDEN 10, AWAY 0 |
| `v204_m_module` | module `initial`, module task, `always_comb` and a GENERATE-scope `for`, with a wildcard-import clone in the same file so the clone map is non-empty | 29 / 1 → **`CMP_EQUAL` 0/0**; TO-GOLDEN 2 (the clone's own loop), AWAY 0. Golden's elab view carries all 12 module/genscope for-loops and every one AGREES |
| `v204_c_clones` | TWO wildcard-import clone copies of one subroutine, one class-typed and one builtin loop | 29 / 1 → **`CMP_EQUAL` 0/0**; TO-GOLDEN 4, AWAY 0 |
| `v204_v_extra` | a NAMED-begin loop body, a loop inside a `fork`, a loop inside a class CONSTRUCTOR, a loop variable shadowing a CLASS PROPERTY, a loop inside a `while` body | 29 / 1 → **`CMP_EQUAL` 0/0**; TO-GOLDEN 8, AWAY 0 |

**Does the CLONE list the loop variable?** No — and neither does golden, anywhere.
`ct204own --forinit` on this verifier's own SeqDriver pair: 491 for-loops, 491
init statements, `notlisted` on both sides for every one, kind-for-kind equal.
The container is `ref_obj::Actual_group` on the body reference, exactly as the
implementer decoded it.

---

## 5. GATES on the VERIFIED binary

See `GATES.r10v204.txt`.

---

## 6. RESIDUES

* **R1 (was the implementer's R1)** — now MEASURED rather than asserted: golden
  leaves every reference to a typedef-alias loop variable unresolved in all four
  views. The verified binary matches. What remains on arm A is the implicit-net
  head, a different family.
* **R2** — the second declarator of `for (int a = 0, b = 1; …)`: golden models
  only `a`; our `netMap` binds references to `b` at emit time, in the clone and
  the home listing alike. Pre-existing, untouched by either patch, and visible
  on `v204_n_nested` as a STILL-WRONG key.
* **R3** — `for (; c; s)` takes `noteUnsupported("for init form")` and both
  binaries exit 4 on arm A. Unchanged.
* **R4** — golden SHARES the home loop variable with every clone; we copy it.
  Judge-invisible (no generated `Compare` reads `VpiParent`).
* **R5** — the `++` operand's column: our `ref_obj` for `s.a++` sits at the
  identifier, golden's at the operator. Judge-invisible; it makes one census key
  read as moved on `v204_t_alias`.
* **R6** — the `AGALL|` census is chain- and column-keyed and therefore stricter
  than the judge; `STILL-WRONG` appears where the judge is satisfied. The
  columns that decide a pass, `AWAY-GOLDEN` and `MOVED-WRONG`, are 0 on every
  arm on the verified binary except the two named residues above.

---

## 7. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm204repro
g++ -O2 -std=c++17 ct204cen.cpp -I ~/.local/include -I ../r10ladder1repro \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct204cen
cd ../r10v204repro
CEN=/tmp/ct204cen bash arms204v.sh <PRISTINE> <BINARY UNDER TEST> /tmp/armsv204
# each arm prints, per view: cmp lines/heads, then
#   TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG / AGREE
# with the golden-vs-golden calibration printed on the same line block.
```
