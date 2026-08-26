# r10v153 — the ADVERSARIAL VERIFICATION of r10uvm153

**VERDICT: ACCEPT-WITH-FIX.**  Every headline number of `r10uvm153` reproduces
**bit for bit** on independently configured, independently built binaries.  One
`RIGHT→WRONG` cell was found on legal SV, its root cause is a **pre-existing**
package-listing defect that § 153 turned into a wrong binding, and it is fixed
here in one guard (`src/ParamEmit.cpp`, § `ctorForInitIsNotAPkgDataDecl153v`).
One durable claim in the pass's write-up was measured on a key the judge does
not read and is corrected in place.

Base commit **34c4dc9**.  LHS is **always** golden (Surelog); RHS is always
ours.  The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else.

---

## 1. BIT-FOR-BIT REPRODUCTION

Two fresh worktrees at 34c4dc9, `cmake -DCMAKE_BUILD_TYPE=Release`, `-j 2`,
`SLANG_UHDM` exported per binary, every `cmds.txt` audited **by binary path**
(over three sweeps per corpus: 4 719 surelog + 4 386 u2r `cmds.txt` files, 4 569 / 4 374 of them naming a frozen binary, **0** naming a main-tree one):

| | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `8504a7f8aab1177cb74916fc8ae55012` | **same** |
| patched binary md5 | `1be8208596e3de248ebae14babb63a30` | **same** |
| goldens pristine / patched | 23 PASS / 0 FAIL | **same**; negative control `SLANG_UHDM=/bin/false` → 23 FAIL |
| surelog, both modes, 1588 rows | 937 EQ / 19 NE / 567 REJ / 48 SL_FAIL / 10 DEF / 3 NO_DB / 2 UNTR / 1 TIMEOUT / 1 NO_UHDM | **same, status for status, on BOTH binaries** |
| u2r both modes | 679 / 50 / 2 | **same** |
| ct8rows vs committed CSVs + own pristine controls | PASS | **PASS** (surelog, u2r tf, u2r def) — **no row converted, `results/*.csv` untouched** |
| byteverify surelog | 9 / 956, the 9 predicted names | **the same 9 paths**, 7 of the 9 hashes byte-identical to the implementer's (Scoreboard/default is the known coin) |
| byteverify u2r | 0 / 1358 | **0 / 1358** |
| heads (`rowheads.sh`) | BuildUVMPkg **45 → 36** both modes, 11 other logs byte-identical | **same**, and all 12 patched head logs are **byte-identical to the committed `head_pat_*.cmp`** |
| wide boundary | `LISTED=4339 PROCESSED=4339 PRODUCED_DBS=4193 MOVED_ARMS=6 RC_DIFFS=0` | **identical line**, same 6 arm names |
| `r10v152repro/arms/v152_h_prop.sv` re-score | 3 W→R, 0 R→W, 0 AWAY; cmp 4912→4910 def, 6788→6774 elab | **identical** |
| grid `ARMS.r10uvm153.txt` (5 arms × 2 views) | 7/2, 13/12, 1/0, 11/11, 9/5; R→W 0, AWAY 0 | **identical, cell for cell, and the 20 uhdm-cmp line counts too** |
| protected DBs | 10 SAME, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **same** |
| canaries / ctcan2 / canaudit | 52, 8, PASS ×2, 29/0/0 | **same** |

**The mover attribution reproduces too.**  Sorted, path-normalised `uhdm-dump`
diffs: BuildUVMPkg / MiniAmiq / Scoreboard **4 lines** each (`+2` `class_var
(uvm_pkg::clp)`, `+2` `|vpiActual:`); SimpleUVM / SeqDriver **11 lines** each
(the same substitution plus the removal of `logic_net (work@top.clp) @339:3`
and its seven stamps).  Scoreboard/default's coin did not fire in this run.

**The head decode is right.**  `uvm_pkg`'s `Variables()` listing is 26 = 26,
element for element — same kinds, same names, same spans, same order — in both
views on both sides, so the head really is a `ref_obj::Actual_group` singular
`<null>`, not a container-position mismatch.  `clp @33188:27` is slot 5 of that
listing.  The patched head is a different object, `func_call
(m_time_settings) @41234:9` — the head the other four UVM rows already carry.

---

## 2. THE ONE `RIGHT→WRONG`, AND THE FIX

### § `ctorForInitIsNotAPkgDataDecl153v`

*A `for (int i = 0; ...)` **control variable** of an out-of-body constructor is
**not** collected into the home package's `Variables()` listing.*

`arms/v153_f_faces.sv` asks every constructor-local listing face at once — the
eaten first element, a body-level local, a nested `begin`, a **doubly** nested
`begin`, a `fork`, a **`for`-init**, a `for` body, a named block, a `case` arm,
a `default` arm, an `if` arm, a class handle, a typedef'd handle, a string, a
queue, a fixed array, three declarators on one line, an initializer that reads
another local, a second constructor reusing the first's names, a local after
`super.new()`, and a package free function beside them — and then reads a class
property of each of those names from one out-of-body method.

Scored against one Surelog golden, `patched` vs `pristine`:

```
DEF   WRONG->RIGHT=19  RIGHT->WRONG=1  AWAY=0
      RIGHT->WRONG  ref_obj|f_forv|133:5-133:11  now OURS-BOUND
                    G=[<bare> , <bare>]  O=[int_var(f_forv)@30:14-30:24^package]
```

`f_forv` is the `for`-loop control variable of donor 1's constructor.  The
`ct153bind` census is only the symptom; `ctlist.cpp` names the cause — the
package `Variables()` listing itself:

```
GOLDEN pvf153  VARS=23   ...  [4] f_fork  [5] f_forb  [6] f_inname ...
OURS   pvf153  VARS=23   ...  [4] f_fork  [5] f_forv  [6] f_forb   ...
```

We collect an entry golden does not have.  It is **pre-existing** — pristine's
listing has it too — and it was invisible until § 153 started reading that
listing **by name** for class properties.

**Surelog, read line by line.**  `CompilePackage::collectObjects_`
(`../Surelog/src/DesignCompile/CompilePackage.cpp:123`) walks the package's
**syntax** and hands only `paData_declaration` block items to
`compileDataDeclaration(m_package, ...)` (:261).  A `for`-loop initialiser is a
`paFor_variable_declaration` — a different node — and never reaches that call.
Ours walked slang's **scopes** instead, and slang materialises the loop
variable as a `VariableSymbol` inside the `for`'s `StatementBlockSymbol`, built
by `VariableSymbol::fromSyntax(..., ForVariableDeclarationSyntax&, ...)` →
`setFromDeclarator(*syntax.declarator)` — so the symbol's syntax is the
DECLARATOR and its **parent** is the `ForVariableDeclaration` node.  That
parent is the whole test, four lines in `collectOobCtorLocals`
(`src/ParamEmit.cpp`).  A `foreach` loop variable is `SymbolKind::Iterator` and
was already outside that walk.

**After the fix:** `v153_f_faces` DEF `WRONG->RIGHT=19 RIGHT->WRONG=0 AWAY=0`,
ELAB `WRONG->RIGHT=20 RIGHT->WRONG=0 AWAY=0`.

**And it lands on § 152's own committed arm as an exact match.**  The wide
boundary (patched → fixed) names exactly two movers, both § 152 position arms,
and on `tools/probe/r10uvm152repro/g152_d_pos.sv` the package listing goes

```
golden   pd152  VARS=16   [14] int_var k @22:12  [15] class_var inner_d @38:13
pristine pd152  VARS=17   [14] int_var k @22:12  [15] int_var i @36:14  [16] inner_d
FIXED    pd152  VARS=16   [14] int_var k @22:12  [15] class_var inner_d @38:13
```

— **byte-identical to golden's listing, both views**, where it previously
carried one spurious element.  No `ref_obj` binding cell moves on either arm
(`WRONG→RIGHT 0 RIGHT→WRONG 0 AWAY 0` in both views) and the official uhdm-cmp
line count falls 11736→11640 (def) / 18950→18854 (elab) on `g152_d_pos` and
11022→10926 / 17914→17818 on `v152_e_pos`.

**Blast radius: nil.**  `byteverify SELFCHECK=1` of the fixed binary against
the patched one is **0 movers / 956** surelog databases and **0 / 1358** u2r —
so every headline number in § 1 above holds verbatim for the shipped binary,
and all twelve head logs are byte-identical to the patched ones.

---

## 3. THE CORRECTION — the hoist-net removal is a small move AWAY

`README.md` of `r10uvm153repro` (and the header law) claimed the removal of
`logic_net (work@top.clp) @339:3` was "a wrong member left, nothing golden has
was lost", scored as `ONLY-OURS 23→22` / `22→21` with `ONLY-GOLD` and `SHARED`
unchanged.  **That census is keyed on the SPAN.**  Reproduced exactly here — and
no generated `Compare` reads `VpiLineNo`/`VpiColumnNo` (RESUME § 9).  On the key
the judge actually reads, kind + `VpiName`, the same `module_inst` `Nets()`
multiset moves the other way (`ctnets.cpp`, def view):

| | golden | pristine | patched |
|---|---|---|---|
| SimpleUVM `Nets()` size | 225 | 211 | **210** |
| SimpleUVM ONLY-GOLD / SHARED (kind+name) | — | 14 / 211 | **15 / 210** |
| SimpleUVM ONLY-GOLD / ONLY-OURS / SHARED (kind+name+span) | — | 37 / 23 / 188 | 37 / **22** / 188 |
| SeqDriver `Nets()` size | 224 | 184 | **183** |
| SeqDriver ONLY-GOLD / SHARED (kind+name) | — | 40 / 184 | **41 / 183** |
| `logic_net clp` in that module | **2** | 1 | **0** |

The net we removed matched one of golden's two on every field the judge reads.
It changes **no verdict** — that vector is 225 vs 210 and fails the size check
either way, and the head moved 45 → 36 regardless — but the durable reading is:
the **binding** half of this law is a move toward golden; the **un-minting**
half is a small move away.  Residue R4 is where the two are reconciled.  Both
the header comment and the pass README are corrected in this patch.

---

## 4. THE OTHER ARMS — everything that did NOT break

`varm153.sh` builds each arm with Surelog (golden) and both frozen binaries in
BOTH views and scores every `ref_obj` binding cell with `ct153bind` +
`score153.py`.  All seven arms, both views: **RIGHT→WRONG 0, AWAY 0.**

| arm | what it asks | def | elab |
|---|---|---|---|
| `v153_a_qual` | `this.` / `super.` / `Class::` / `pkg::` qualified reads of a colliding property, and a **dynamic-array `= new[]` lvalue** | 4 W→R | 0 |
| `v153_b_home` | the same collision in a **PROGRAM** class and an **INTERFACE** class beside the package one | 1 W→R (package only) | 0 |
| `v153_c_order` | **two listing entries of the same name in BOTH orders** — a hoisted ctor local before the real package variable, and one after | 2 W→R | 0 |
| `v153_d_hoist` | a module that **wildcard-imports** the package: a colliding name (the mint is replaced) beside a non-colliding one (**the mint must survive**) | 2 W→R | 0 |
| `v153_e_shape` | `foreach` body, `fork`, named block, `do/while`, `repeat`, `$cast` argument, **queue receiver**, **assoc-array lvalue**, **array-element receiver**, **two-element hier_path** | 7 W→R | 7 W→R |
| `v153_f_faces` | every constructor-local listing face (§ 2) | 19 W→R | 20 W→R |
| `v153_g_edge` | a **nested class**, a property colliding with a package **PARAMETER**, one colliding with a **TYPEDEF**, a constraint / `randomize() with` reference, an out-of-body **static** method | 3 W→R | 0 |

Findings inside those arms, none of them a regression:

* **the three fences hold under collision.**  `v153_e_shape` asks a queue
  receiver, an assoc-array lvalue, an array-element receiver and a two-element
  `hier_path` of properties that all collide with real package variables:
  `SAME=21`, not one mismatched cell in the DEF view.
* **a `::`-scoped static property is bare by construction.**  Golden and ours
  both name that `ref_obj` `<Class>::@@BAD_SYMBOL@@`, so the listing lookup
  cannot match it (`v153_a_qual` @32).
* **first-match-wins is our order too.**  `v153_c_order`: the hoisted ctor
  local wins when it is EARLIER (`x_early` → the ctor copy @10:9), the real
  package variable wins when IT is earlier (`x_late` → @15:10).  Both agree
  with golden.
* **the hoist mint survives where it must.**  `v153_d_hoist`: golden's module
  keeps `logic_net y_miss` and so do we; only the colliding `y_hit` references
  move to the package variable.
* **a package PARAMETER collision stays bare** — golden binds a folded
  `constant()@7:25^param_assign` through another mechanism, we stay bare on
  both binaries (residue R3, unmoved, no AWAY).
* **a `dynamic-array `= new[]` lvalue BINDS in golden**, and now in ours
  (`v153_a_qual` `v_dyn` @34, W→R) — the `= new` fence is § 109's **class**
  construction only.

---

## 5. RANKED RESIDUES THE VERIFICATION ADDS

1. **A latent `super.`-qualified trap.**  `super.v_sup = p` on a colliding
   property: golden builds a `hier_path` whose leaf `ref_obj` is **BARE**; we
   build a plain `ref_obj` and now BIND it.  Harmless today — the assignment's
   `Lhs` is `hier_path` vs `ref_obj`, a type mismatch the judge already fails on
   — but the day the `super.` shape is fixed (uvm84/85 family), § 153 will bind
   a leaf golden leaves bare unless the hier_path fence is extended.
2. **A fixed unpacked-array constructor local is MISSING from our package
   listing.**  `v153_f_faces`: golden's `pvf153` listing carries `array_var
   f_arr @59:12`, ours does not (a queue `f_q` at the same nesting IS carried).
   Pre-existing, unchanged by this pass or the fix; after the fix our listing is
   a strict subset of golden's (22 correct entries vs golden's 23).
3. **A typedef'd class handle's listing entry has the wrong KIND in one view.**
   Golden's un-elaborated `pvf153` listing holds `logic_var f_alias @56:12`
   where ours holds `class_var`; the elaborated listing holds `class_var` on
   both sides.  Surfaced (not caused) by § 153 as a `DIFF` binding.
4. **`ct153bind` hides `DIFF`/`ONLY-*` rows without `--all`.**  `score153.py`'s
   loader matches those row kinds, so a grid run without `--all` would silently
   score "both bind, different targets" as agreement.  The pass DID pass
   `--all` (its reports contain `DIFF` rows) — recorded so the next user of the
   instrument does too.
5. **`pkgListingByName153` does not model Surelog's `uhdmref_var` /
   `uhdmref_obj` skip.**  `UhdmWriter::lateBinding` (`:3410-3428`) `continue`s
   past a listing entry of those kinds and takes the next same-named one; our
   helper takes the first match unconditionally.  Latent only — our package
   listings never hold a `ref_var` (all eight `MakeRef_var` sites are statement
   contexts; `src/ParamEmit.cpp:22845`) — and § 81's `pkgVarOverFormal81` has
   carried the same simplification since pass 81.  Same for the
   `m->VpiName() + "::" + name` second-chance match in the same loop.

---

## 6. FILES

* `arms/v153_[a-g]_*.sv` — the seven adversarial arms.
* `varm153.sh` — `PRIS=… PATCHED=… BIND=… SCORE=… varm153.sh <arm.sv>`: Surelog
  golden + both binaries, both views, cell-by-cell score, official uhdm-cmp
  line/head counts.  Every child gets `</dev/null`; every rc is printed.
* `ctlist.cpp` — the package `Variables()` listing **in order**, with kinds and
  spans.  This is the instrument that named § 2's cause.
* `ctnets.cpp` — `module_inst` `Nets()` vector sizes and members; § 3's
  instrument.
* `GATES.r10v153.txt` — every gate, both binaries, with the audits.

Build the two probes with
`g++ -O2 -std=c++17 <file>.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <file>`.
