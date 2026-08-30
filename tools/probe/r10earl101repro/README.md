# r10earl101 — § `elabVecPortTdElemBare101`

**A packed-vector PORT's element typespec spells a package scalar typedef
per VIEW: qualified in the `AllModules` def listing, BARE in the elaborated
instance — and both alias back to the qualified listing object.**
`Earlgrey_0_1` went from **132 cmp lines / 1 head** to **58 (default) / 62
(testflags) / 1 head** in *both* modes; the queued `hmac_pkg.sv:17` typespec
name is cleared. Two Earlgrey databases moved, both predicted by name from
pristine databases; nothing else in 2314 databases moved a byte.

Everything in this directory is **MEASUREMENT ONLY**. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.

---

## 1. The head, and its OWNER, decoded before a line of law was written

`rowheads.sh` on this pass's own pristine build (`12ca2375a652`):
`Earlgrey_0_1` **132 cmp lines, 1 head, both modes, byte-identical logs** —
re-measured, not carried forward, and byte-identical to
`r10earl100repro/HEAD_BEFORE_Earlgrey_*.cmp`.

```
hmac_pkg.sv:17   typedef logic [31:0] sha_word_t;

LHS (golden)  logic_typespec #462455  VpiName `sha_word_t`
                Typedef_alias -> ref_typespec -> logic_typespec #32639
                                                 `hmac_pkg::sha_word_t`
                Instance -> package hmac_pkg
RHS (ours)    logic_typespec #772214  VpiName `hmac_pkg::sha_word_t`
                Typedef_alias -> ref_typespec -> logic_typespec #27866
                                                 `hmac_pkg::sha_word_t`
                Instance -> package hmac_pkg
```

`typespec::Compare`
(`~/git-repos/UHDM/build/generated/src/typespec.cpp:88-94`) reads **VpiName,
then Typedef_alias, then Instance**, and sets `m_failedLhs`/`m_failedRhs` on
the *name*. Both sides' alias targets are the qualified listing object and
both instances are `package hmac_pkg`, so the failing field is the **copy's
own VpiName** and nothing else.

### The owner (`own101`, the reverse reference scan — `OWNER.r10earl101.txt`)

The head print names the object, not who holds it. `own101` walks the whole
arena for every `ref_typespec` whose `Actual_typespec` is the head object and
resolves each owner:

| | owners of the head object |
|---|---|
| **golden** | **ONE** — `ref#462460` ← unnamed `logic_typespec` 27:10-27:26 ← `port digest` ← `module_inst work@top_earlgrey.u_hmac.u_sha2` (the **ELAB** instance) |
| **ours** | **TWO** — the same elaborated `port digest`, **and** `port digest` of `module_inst work@sha2` (the **DEF** listing) |

So the owner is **`sha2.sv:27`, `output sha_word_t [7:0] digest`** — a
packed-vector port of a package scalar typedef, reached by the field path

```
design > TopModules > … > module_inst u_sha2 > Ports > port digest
       > Typespec (ref_typespec) > logic_typespec 27:10-27:26 (unnamed, EQUAL)
       > Elem_typespec (ref_typespec) > THE HEAD
```

and **we share one object between the two views** where golden mints two.

> **Why the port and not the net.** The same `digest` is also a `logic_net` of
> the elaborated instance, and there our typespec differs from golden's too
> (R1). It is not the head because `nets::Compare` (`nets.cpp:240-300`) never
> reads `Typespec()` — it reads VpiArrayMember, VpiConstantSelect,
> VpiExpanded, VpiImplicitDecl, VpiName, VpiNetDeclAssign, VpiNetType,
> VpiResolvedNetType, VpiScalar, VpiExplicitScalared, VpiSigned — while
> `ports::Compare` (`ports.cpp:176`) **does**. Read the generated Compare, not
> the decompile.

---

## 2. The decoded model — Surelog, read verbatim

`UhdmWriter::writeDataTypes`
(`Surelog/src/DesignCompile/UhdmWriter.cpp:775-796`) is the only place a
typespec's name acquires a package qualifier, and it applies it **in place, on
the shared object**, while the *package* listing walk runs:

```cpp
if (parent->UhdmType() == uhdmpackage) {
  if (tps && (tps->VpiName().find("::") == std::string::npos)) {
    const std::string newName = StrCat(parent->VpiName(), "::", tps->VpiName());
    tps->VpiName(newName);                 // IN PLACE
  }
}
```

Three consequences, each measured here rather than assumed:

1. **Only the object that walk touched carries the prefix.** The `AllModules`
   def entry for `sha2` reuses that very object as its port's
   `Elem_typespec`, so the **def** cell is qualified — which is what r10earl18
   measured and encoded.
2. **The elaborated instance re-compiles the port's declared type in the
   instance's own scope**, and what comes back is the ordinary
   per-declaration copy: **bare**, with a `Typedef_alias` back at the prefixed
   listing entry. That is LAW S's rule, and the port element obeys it — the
   split is per *view*, not per *site*.
3. **It is not an import clone.** `writeImportedSymbols` (:1307-1396) clones
   and re-names only for an **explicit** single-symbol import (its
   `item->Item()` decompile is the symbol name). `sha2` carries
   `import hmac_pkg::*;`, whose decompile is `"*"` and matches no package
   typespec, so nothing is cloned. `g2_form101` scores all four import forms
   directly and the answer is the same in every one.

Golden's own two spellings of the *same* port, quoted from the census:

| view | owner | `ts>e` | `ts>e>a` |
|---|---|---|---|
| `D` | `work@sha2` | `hmac_pkg::sha_word_t` | `hmac_pkg::sha_word_t` |
| `E` | `work@top_earlgrey.u_hmac.u_sha2` | **`sha_word_t`** | `hmac_pkg::sha_word_t` |

### Which earlier residue is this? — *none of them*, measured

The brief asked whether the owner is `r10earl96`'s R1 / R2 / R3 or
`r10earl97`'s V-R1. It is **none**, and each is excluded by a measurement, not
by argument:

* **earl96 R1** (a typedef of a typedef takes no LAW-S copy) — `sha_word_t` is
  `typedef logic [31:0]`, a direct scalar typedef; its alias chain is one hop,
  not two. `g1_kind101` carries a real alias-of-an-alias (`vec2_t`) beside it
  and that row does not move.
* **earl96 R2** (the bare copy's first character cut off) — our name is
  `hmac_pkg::sha_word_t`, not `mac_pkg::sha_word_t`; the mangling case is a
  listing object with **no** `::`, which is why this law carries an explicit
  `find("::")` guard and why `g5_neg101` puts a `$unit` typedef under a packed
  dimension as its control.
* **earl96 R3** (a module-local typedef of a package typedef loses its
  `vpiInstance`) — both sides' `vpiInstance` is `package hmac_pkg`, and
  `typespec::Compare` never reached `Instance()` because it stopped at
  `VpiName`.
* **earl97 V-R1** (a cast target declared through a typedef reuses the
  typedef's named typespec) — there is no cast here; the owner is a port.
  `g3_site101` carries a cast target of the same typedef as a control and it
  does not move.

---

## 3. The law

`src/TypeEmit.cpp`, inside `bareScalarTypedefVarTs()` — r10earl18's
`§ portVecTdElemClone18` gains a **view** in its memo key:

```cpp
std::map<std::pair<const UHDM::typespec*, bool>, UHDM::typespec*> qualTdElemCopy18;
…
const bool bare101 =
    elabView101 &&
    std::string_view(at->VpiName()).find("::") != std::string_view::npos;
auto key18 = std::make_pair((const UHDM::typespec*)at, bare101);
…
UHDM::typespec* cp18 = bareScalarTdCopyOfFresh16(at);   // already BARE-named
if (cp18) {
    if (!bare101)
        cp18->VpiName(at->VpiName());                   // the DEF view re-qualifies
    …
}
```

and the caller reads the view **off the PORT**, because the element ref itself
is unparented (the wrapper typespec is minted per declaration and never
adopted — `own101` prints `SELFPAR <- <null>` for it):

```cpp
rebindQualElem18(((UHDM::logic_typespec*)pat18)->Elem_typespec(),
                 elabOwned101(pt18));
```

`elabOwned101` climbs ≤8 parents to the first `module_inst` /
`interface_inst` / `program` and asks whether it is in `design->AllModules()` /
`AllInterfaces()` — the design's own two lists, never a name heuristic (a def
entry's `vpiName` is empty and its `vpiDefName` names the module, but an
elaborated *top* instance shares both).

Three properties that make the law safe by construction:

* **`bare101 == false` reproduces r10earl18 byte for byte.** The def arm is
  untouched.
* **The aggregate kinds never reach the site**: `pkgScalarTd` holds scalar
  typedefs only (LAW S r7), so the eleven `struct`/`enum` packed-vector port
  elements Earlgrey carries cannot move.
* **The `find("::")` guard** keeps r10earl96 R2 out: `bareScalarTdCopyOfFresh16`
  derives the bare name as `qn.substr(qn.rfind("::") + 2)`, which on a name
  with no `::` wraps to 1 and eats the first character. An unqualified listing
  object keeps r10earl18's arm.

`+81 / −8` lines, one file, nothing else.

---

## 4. The census (`CENSUS.r10earl101.txt`, `CEN_*_pris.txt`)

`ct101cen` keys every typespec-bearing site of every root **TOP-DOWN by the
FIELD PATH the walk took** (`ts`, `ts>a`, `ts>e`, `ts>e>a`, …), never by
`VpiParent` — the two producers park these objects on different parents and no
generated `Compare` reads `VpiParent`. The payload is **compare-visible only**:
`kind | VpiName | vpiInstance kind+name | span`. It carries no id and no
fullname, so object identity and parenting are invisible to the scorer exactly
as they are to the judge. `reg3_101.py` joins the three sides as **multisets**.

**Calibration.** On the 1358 `CMP_EQUAL` uhdm2rtlil databases the instrument
reads **7040 BOTH-SAME / 48 ONLY-GOLDEN / 46 ONLY-OURS**, and every one of
those one-sided rows is an `enum_typespec` element in a single test
(`VarPassedTo2Submodules`) — outside this law's shape by construction. **The
law's own population there is ZERO cells.**

**The denominator.** Over the whole surelog corpus (956 databases) the shape —
a `PORT`'s `ts>e` link whose payload is a *scalar* kind with a *package*
`vpiInstance` — has exactly **four** cells, all `Earlgrey_0_1`, all the same
port:

```
D work@sha2                       PORT digest ts>e  golden QUAL  ours QUAL   x2 modes
E work@top_earlgrey.u_hmac.u_sha2 PORT digest ts>e  golden BARE  ours QUAL   x2 modes
```

**After the law**, re-scored over the same fixed universe with the golden side
asserted byte-unchanged:

| Earlgrey | BOTH-SAME | ONLY-GOLDEN | ONLY-OURS |
|---|---|---|---|
| default | 20064 → **20065** | 45 → **44** | 32 → **31** |
| testflags | 23963 → **23964** | 45 → **44** | 5289 → **5288** |

**TO-GOLDEN 1 · AWAY-GOLDEN 0 · ADDED 0 · REMOVED 0**, in each mode. Both
one-sided sets drop by exactly one row — the arithmetic proof that the law
renames one object and adds and removes nothing. The population counters now
match golden exactly: `D|QUAL 1  E|BARE 1` on both sides, both modes.

---

## 5. The grids (`ARM101.r10earl101.txt`)

Six purpose-built arms, each built by Surelog and by BOTH frozen binaries in
BOTH views (`arm101.sh`; every child `</dev/null`), scored by `uhdm-cmp`
against the same golden **and** by the three-way census:

| arm | axis | plain TO-GOLDEN / AWAY | elab TO-GOLDEN / AWAY |
|---|---|---|---|
| `a1_head101` | the head, reduced: a package scalar typedef, a wildcard import, `output word_t [NumWords-1:0]` on an instantiated submodule | **1 / 0** | **1 / 0** |
| `g1_kind101` | typedef KINDS: logic vector / a scalar logic typedef with no range / enum / packed struct / packed array / a typedef-of-a-typedef, plus a no-packed-dim control of each | **4 / 0** | **4 / 0** |
| `g2_form101` | import FORMS: wildcard / EXPLICIT single-symbol / scoped use with NO import / a `$unit` import | **6 / 0** | **6 / 0** |
| `g3_site101` | use SITES: port / net / variable / parameter / cast target / a nested typedef / a function return + formal / a struct member | **2 / 0** | **2 / 0** |
| `g4_home101` | HOMES: the top module's own port / a submodule / a submodule of a submodule / a GEN SCOPE / an INTERFACE / **three instantiations of one span** | **19 / 0** | **23 / 0** |
| `g5_neg101` | the NEGATIVE CONTROL | **0 / 0 — databases BYTE-IDENTICAL** | **0 / 0 — BYTE-IDENTICAL** |

**ADDED 0 and REMOVED 0 on every arm and every view**, and
`GOLDEN-ONLY-KEYS` / `OURS-ONLY-KEYS` are unchanged everywhere — the law adds
and removes no object.

`g4_home101` is the arm that proves the memo key: the def listing is written
once and the three elaborated instances (`u_i1` / `u_i2` / `u_i3`), the two
gen-scope copies (`gblk[0].u_g` / `gblk[1].u_g`), the interface and the top
module's own port each take the bare copy while the def entry keeps the
qualifier. Every moved row reads `p4h101::h_t` → `h_t` at an `E`-view
`PORT … ts>e`, matching golden exactly.

**`g2_form101`'s cmp lines GREW (66 → 193/197) while its census improved
(TO-GOLDEN 6, AWAY 0).** That is a MASK CASCADE, not a regression: with the
typespec-name head cleared, the judge advances to a pre-existing
`vpiVariables` size mismatch on `work@g2_form101.u_scope`, whose printed
subtree is larger. Cmp-line counts are a SIZE, never a distance — the census
and the official head are the arbiter (RESUME §9).

**`g5_neg101`** — a module-local typedef under a packed dimension, a `$unit`
typedef (the r10earl96-R2 mangling case), the package's own two views of its
own typedef, package aggregate typedefs on packed-vector ports, and a package
scalar typedef on a port with **no** packed dimension — produces
**byte-identical databases on both binaries in both views**.

---

## 6. Gates

* Binaries frozen `chmod 555` at immutable paths: pristine `01603ea`
  `12ca2375a652`, patched `2eaa7a60ddb4`; md5 taken separately from the build.
* `check_goldens.sh` with `SLANG_UHDM` exported **to each binary**:
  **23 PASS / 0 FAIL** on both; negative control `SLANG_UHDM=/bin/false`:
  **0 PASS / 23 FAIL** (the control fires).
* Status histograms, patched vs this pass's own pristine sweep — **identical**:
  surelog default 471 CMP_EQUAL / 283 SLANG_REJECT / 25 SURELOG_FAIL /
  10 CMP_NOTEQUAL / 5 DEFERRED; testflags 466 / 284 / 23 / 9 / 5 / 3
  NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM;
  uhdm2rtlil **679 / 50 / 2** in **both** modes.
* `ct8rows` **PASS** on all five comparisons (u2r-tf vs the committed
  `results/gate_uhdm2rtlil.csv` in this worktree; u2r-tf, u2r-def and sl vs
  this pass's own pristine sweep; sl vs the committed
  `results/golden_surelog.csv`). `results/*.csv` untouched. **No row converts**
  — the two `Earlgrey_0_1` rows were and remain `CMP_NOTEQUAL`.
* `byteverify SELFCHECK=1`, patched vs this pass's own pristine sweep:
  **uhdm2rtlil MOVERS 0 / 1358** (SELFCHECK 1357/1358 flagged),
  **surelog MOVERS 2 / 956** — `./default/Earlgrey_0_1` and
  `./testflags/Earlgrey_0_1`, **exactly the predicted set and nothing else**
  (SELFCHECK 955/956 flagged, `PATH_SETS_IDENTICAL` on both).
* Every `cmds.txt` audited **by binary path**: **0 of 6070** name the main-tree
  binary.
* `canaries.sh` `ok=52 changed=0 absent=0` (surelog) and `ok=8 changed=0
  absent=0` (u2r); `ctcan2.sh` **PASS** on both;
  `canaudit.sh canaries.sh ctcan2.sh` from THIS directory
  **audited=29 UNCOVERED=0 FENCE-BREACH=0**.
* Protected databases by name, patched vs pristine, **both modes**:
  `InterfaceModPort` `BlackParrotComplex` `YosysOldOr` **SAME**;
  `SVSwitch` **`4842211c4030`**; `YosysVerx` **`6ccda350c24a`**.
* `rowheads.sh`, pristine → patched: SeqDriver 29/29, SimpleUVM 29/29,
  Scoreboard-default 145/145, MiniAmiq 106/106, BuildUVMPkg 321/321,
  Rggen-default 0/0 — **every one unchanged**; **Earlgrey_0_1 default
  132 → 58 and testflags 132 → 62**, one head throughout.
  (`SKIP-NOFILE` on Scoreboard/testflags and Rggen/testflags as expected.)

### The wide boundary (`BOUNDARY_WIDE.*`)

**4613 files**, both views, both frozen binaries, workdir-normalised dump
byte-compare, file list on **fd 3**, children `</dev/null`,
**PROCESSED = LISTED = 4613**.
`identical 8835 · DIFFERING 19 · no_output 372`; rc histogram
`0:16962 3:716 4:746 139:28`, and **symmetric side for side**
(`rc=0 8481/8481, rc=3 358/358, rc=4 373/373, rc=139 14/14` — R5).

**All 19 differing cells are attributed:**

1. **10 = five of this pass's own arms × 2 views** — the **positive control**
   (the gate can see the law), and `g5_neg101` is in the list and correctly
   **absent** from the diff.
2. **`r10earl77repro/g1_portkind77.sv` ×2** — the law fires on
   `i_pkgvecdim` / `o_pkgvecdim` (`p77::v8_t [N:0]`, elaborated view) and moves
   18 dump lines `p77::v8_t` → `v8_t`, but **golden has no `ts>e` key there at
   all**: golden's port carries a scalar `p77::v8_t` and no wrapper (earl100
   R4 / R2 below). cmp lines **37725 → 37725**, head log **byte-identical**,
   census **TO-GOLDEN 0 / AWAY 0 / ADDED 0 / REMOVED 0** — equidistant, and the
   cell belongs to R4's family.
3. **`r10earl88repro/g1_elemdims88.sv` ×2** — the head log differs in **id
   numbers only** (`id:5702` → `id:5706`, a +4 shift from the two extra
   objects the split memo mints); every name, kind and span identical, cmp
   lines **43533 → 43533**, census **0 / 0 / 0 / 0**. No generated `Compare`
   reads an id.
4. **`r10buvm22repro/g22.sv` ×2** and **`r10uvm154repro/l154_noenum.sv` ×2** —
   the whole diff is the one layout-derived garbage constant uvm154 §7 /
   earl99 R7 / earl100 characterised (`22531801` → `22535897`). Head logs
   **byte-identical**, cmp lines identical (8753/8753 and 816/816), census
   **0 / 0**.
5. **`r10vrgg3repro/xi_iface_param_type/dut.sv` ×1 (elab)** — a
   **nondeterminism**, not a law effect: one added `|vpiSigned:1` on the
   empty-named `parameter` of the interface-array element `work@top.arr[0]`.
   Re-run in place, the two frozen binaries produce the **identical** database
   (`a90b30ca70d4`, 5/5 runs each); the **same** binary run in the two staging
   directories produces identical normalised dumps; and **ten boundary-style
   repeats of the pair differ 0/10**. Recorded as R4 in `PREDICT_R0.txt`.

**Zero unattributed movers.**

**FENCED=** the four slang-fenced test names are not spelled anywhere in this
directory except inside `canaudit.sh`, which carries them as its fence list
(the same convention every earlier pass follows, so the integrator's
`awk … | grep -v canaudit | grep -c .` fence check reads **0** on this patch).
The 4613-file boundary list was filtered by those four names before a single
child ran, and the filter matched **0 files** — none was dispatched.

---

## 7. R0 and the residues

Carried in full in `PREDICT_R0.txt`. In one line each:

* **R0 — the new head, both modes, one object.** `pinmux_pkg.sv:20`,
  `parameter int MioStrapPos [0:NStraps-1]`: golden **folds** `NStraps-1` to
  the constant `1` (stamped at the identifier's span 20:32-20:39) where we
  keep the symbolic `operation` (opType 11) with a bound `ref_obj NStraps`.
  `range::Compare` reads `Left_expr`/`Right_expr`, so the head is the
  expression's KIND. The two modes differ by two lines and only in our print
  (testflags' `ref_obj` carries `vpiActual`, default's does not).
* **R1** — the same `digest`'s elaborated **NET** binds the packed-vector
  wrapper where golden binds the scalar listing object. Judge-invisible today
  (`nets::Compare` does not read `Typespec()`), identical on both binaries.
* **R2** — a `pkg::vec_t [N:0]` port is not a wrapper at all in golden
  (earl100 R4, re-measured here from the wide boundary's own attribution).
* **R3** — the non-port element sites (net / variable / parameter / cast /
  nested typedef / function return / struct member), still 55 OURS-ONLY and
  101 GOLDEN-ONLY rows on `g3_site101`, each owned by a law already in tree.
* **R4** — the `xi_iface_param_type/dut.sv` nondeterminism, proved not a law
  effect (0/10 repeats).
* **R5** — the pre-existing probe/boundary segfaults, rc histogram symmetric
  side for side.

---

## 8. Files

| file | what |
|---|---|
| `ref101.cpp` | the reverse reference scan: every typespec matching a name, with the FIELD PATH the `UhdmListener` walk took to it and to every `ref_typespec` that names it as `Actual_typespec` |
| `own101.cpp` | the owner finder: for a given uhdm id, every `ref_typespec` and every alias ref that points at it, each with its own parent chain, plus every scope whose `Typespecs()` lists it |
| `ct101cen.cpp` | the census: every typespec-bearing site of every root, keyed by field path, payload compare-visible only |
| `cen101.py` | the corpus driver + population counter over a `verify_golden` workdir (`POPROW=1` dumps the population rows themselves) |
| `reg101.py` | the two-way per-key multiset scorer |
| `reg3_101.py` | the THREE-way scorer: TO-GOLDEN / AWAY-GOLDEN / ADDED / REMOVED / MOVED-WRONG |
| `arm101.sh` | the arm scorer: every arm × {plain, elab} × {pristine, patched} against a Surelog golden built in place |
| `wide101.sh` | the wide boundary (fd-3 list, `</dev/null` children, `PROCESSED` asserted) |
| `a1_head101.sv` | the head reduced to one file |
| `g1_kind101.sv` | typedef kinds × the packed-vector port element |
| `g2_form101.sv` | import forms (wildcard / explicit / scoped / `$unit`) |
| `g3_site101.sv` | use sites |
| `g4_home101.sv` | homes, incl. three instantiations of one span, a gen scope and an interface |
| `g5_neg101.sv` | the negative control — byte-identical on both binaries |
| `OWNER.r10earl101.txt` | the raw owner scan, both databases |
| `CENSUS.r10earl101.txt` | the three-way Earlgrey census, both modes, with the moved cell quoted |
| `CEN_sl_pris.txt` / `CEN_u2r_pris.txt` | the pristine corpus censuses and the population counters |
| `ARM101.r10earl101.txt` | the arm table and the per-arm three-way census |
| `BOUNDARY_WIDE.*` | the wide boundary: tally, diff, rc histogram, rc by side, and every differing cell attributed |
| `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp` | the head logs, both modes |
| `PREDICT_R0.txt` | the mover prediction (made from pristine databases) and R0 |
| `byteverify.sh` `canaries.sh` `canaudit.sh` `ct8rows.sh` `ctcan2.sh` `rowheads.sh` | the standing gate scripts, carried so this directory is self-contained |
