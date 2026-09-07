# r10v194 — ADVERSARIAL VERIFICATION of r10uvm194 (§ `homeRetNameSelBindSurvivesDefViewUnbind194`) — **ACCEPT**

**MEASUREMENT-ONLY probes.** Nothing here is an acceptance judge; the official
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are. slang was **NOT** patched; `results/*.csv` were **READ ONLY** and **NOT
EDITED** (both md5s re-checked against the pristine worktree); `GOLDEN_DEFER`
stayed unset; the four slang-fenced tests were never dispatched and are named
only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `287bbc94`, fresh worktrees `/tmp/wt_v194` (patched) and `/tmp/wt_v194pris` (pristine) |
| pristine binary | md5 `982e5776891c48fb0e30ab832c3c05d4` — **byte-identical to the main tree's `build/slang-uhdm`**, built independently here |
| patched binary | md5 `d9d6c87f4c7163b532bbb2c719e0991a` — **the implementer's number, reproduced bit-for-bit from a fresh apply** |
| verdict | **ACCEPT, no fix required.** No pristine-RIGHT → patched-WRONG cell was found on any of 5 new arms (18 faces), 3 re-run implementer arms, 2 re-run r10uvm171 arms, or 2314 corpus row-modes. |

---

## 1. WHAT THE PATCH CAN AND CANNOT DO — the structural bound

The whole production surface is ONE clause inside
`classRetNameDefViewNoBind37`'s unbind loop (`src/TypeEmit.cpp`):

```cpp
const bool cloneTf194 = pkgImportCloneTfs16.count(tf) != 0;
for (auto* r : refs)
    if (r && !(!cloneTf194 && funcRetSelBound.count(r)))
        r->Actual_group(nullptr);
```

It can only **SKIP a null-out**. It mints nothing, moves no emission site,
creates no object and changes no ordering. So the *only* regression it can
produce is *"we keep a binding golden does not have"*, and the only cells at
risk are references `endSelTrack` put in `funcRetSelBound`. That bound is
confirmed by measurement three ways:

* the census `CAND` count is **identical on golden, pristine and patched** in
  every arm (arm B: 24/24/24), so no object is minted;
* every whole-dump order-blind diff between the two binaries, on every arm and
  both corpus movers, is **pure ADDITION of `vpiActual:` + a `bit_select` face —
  ADDED=n, REMOVED=0**, never once a removal or a changed line;
* `funcRetSelBound` is fed at `src/StmtEmit.cpp:388` and `:441` only when
  `funcRetSym && wr.sym == funcRetSym`, and `funcRetSym` is `sub.returnValVar`
  (`TaskFuncEmit.cpp:6520`) — **null for a task and for a void function**, which
  is why arm B's `b_void` and `b_task` contribute ZERO census rows on all three
  sides.

## 2. HEADLINE NUMBERS, REPRODUCED INDEPENDENTLY

Both binaries built here from scratch (`-j 2`), frozen `chmod 555` at
`/tmp/v194_bins/`, and **every** `cmds.txt` of **every** sweep audited by binary
PATH: 1523/1523 surelog rows and 1458/1458 u2r rows per side named the intended
frozen binary; not one row reached the main-tree build.

| claim | implementer | measured here |
|---|---|---|
| patched binary md5 | `d9d6c87f…` | `d9d6c87f4c7163b532bbb2c719e0991a` ✔ |
| pristine binary md5 | `982e5776…` (= main tree) | `982e5776891c48fb0e30ab832c3c05d4` ✔ |
| goldens | 23/0 both binaries, `/bin/false` 0/23 | 23/0, 23/0, 0/23 ✔ |
| BuildUVMPkg head | 31 lines / 1 head → 0 / 0 | ✔ and the pristine `.cmp` is **byte-identical** to the committed `head_pris_BuildUVMPkg.default.cmp` |
| surelog rows changed | exactly 2, both CONVERSIONS | ✔ exactly 2 (below) |
| surelog byte movers | 3/956 (2 predicted + the Scoreboard coin) | **2 / 956** — only the two predicted; the coin did not flip this run. SELFCHECK 955/956 |
| mover attribution | +4 / −0 each, UNATTRIBUTED 0 | ✔ `ADDED=4 REMOVED=0 UNATTRIBUTED=0` on each |
| u2r | 0 movers / 1358, three `ct8rows` PASS | ✔ 0/1358, SELFCHECK 1357/1358, three PASS |
| grid TO-GOLDEN / AWAY / MOVED-WRONG | 48 / 0 / 0 | ✔ 12 + 24 + 12 = **48 / 0 / 0** |
| r10uvm171 arms | TO-GOLDEN 6 / 0 / 0 each | ✔ 6 / 0 / 0 each |
| SVSwitch / YosysVerx pins | `4842211c4030` / `6ccda350c24a` | ✔ both HELD, both modes |

### The conversion, quoted from my own `ct8rows` run

```
---- WHOLE-ROW diff (status AND dump column): 2 differing ROWS (4 diff row-sides)
< BuildUVMPkg,default,CMP_NOTEQUAL,decompile:,,
< BuildUVMPkg,testflags,CMP_NOTEQUAL,decompile:,,
> BuildUVMPkg,default,CMP_EQUAL,,,differ
> BuildUVMPkg,testflags,CMP_EQUAL,,,differ
```

The same two rows and no other against the committed `results/golden_surelog.csv`
AND against my own pristine sweep — which itself is `PASS: every row
byte-identical to the committed baseline`, so the baseline is not stale.
Status histograms move by exactly `CMP_EQUAL +1 / CMP_NOTEQUAL −1` per mode and
**no new `SLANG_REJECT`**, which is the check that convicts a hidden rc=139.

The two byte movers attribute to nothing but the law's own face:

```
./default/BuildUVMPkg-…/slang.uhdm    ADDED=4 REMOVED=0 UNATTRIBUTED=0
./testflags/BuildUVMPkg-…/slang.uhdm  ADDED=4 REMOVED=0 UNATTRIBUTED=0
	  |vpiActual:                                                        (×2)
	  \_bit_select: (uvm_pkg::uvm_packer::unpack_string::unpack_string), line:22952:7  (×2)
```

## 3. THE DECODE, RE-RUN — the implementer's refutation of the brief holds

`ct194own` on my own pristine BuildUVMPkg database reproduces the owner scan
exactly. Two `bit_select(unpack_string)@22952:7` heads exist:

* the CLASS-listed copy (`<function:unpack_string <class_defn:uvm_packer`) —
  `owners=4 null-on-ours=0`;
* the PACKAGE-listed copy (`<function:uvm_packer::unpack_string <package:uvm_pkg`)
  — `owners=4 **null-on-ours=2**`, and the two null edges are the `vpiActual`
  (relation **700**) of the bare `ref_obj(unpack_string)` at **22943:5** and
  **22943:22**, NOT the `assignment`'s `vpiLhs` (edge 77), which is **present on
  both sides**. The brief's "the owner is the assignment" framing is refuted; the
  head's own `vpiParent` is the trap RESUME §9 names.

Both halves of the Surelog model are verbatim in
`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp`:

* `:3296` `if (ref->Actual_group()) continue;`
* the `uhdmfunction` arm `if (parent->VpiName() == name)` → `clone_tree(func->Return())`
* the `uhdmbegin` arm: `Variables()` first (skipping `ref_var`/`ref_obj`), then
  `Parameters()`, then a scan of `Stmts()` for an `assignment` whose
  `Lhs()->VpiName() == name` (again skipping a `ref_var`/`ref_obj` lhs) →
  `ref->Actual_group((expr*)lhs)`.

And the "why uvm-1.2 lacks the face" claim is exact at the source. The 1800.2
pp_output has both statements DIRECT in the same `begin`:

```
22943:      unpack_string = {unpack_string," "};
22952:      unpack_string[i] = m_bits[m_unpack_iter +: 8];
```

while `uvm-1.2/src/base/uvm_packer.svh:1010-1029` writes

```systemverilog
    unpack_string = {unpack_string," "};
    if(big_endian == 0)
      unpack_string[i] = m_bits[count +: 8];
    else begin … end
```

so the select is not a direct statement of the enclosing `begin` and the four
uvm-1.2 rows have no such cell to move — corroborated by 954/956 databases
staying byte-identical.

## 4. BREAKING THE LAW — 5 NEW ARMS, 18 FACES, ONE REAL SURELOG GOLDEN EACH, BOTH VIEWS

Every arm is scored as a MULTISET join of `ct194cen` listings with the DEF and
ELAB views kept in SEPARATE rows.

```
arm            view   AGREE  TO-GOLDEN  AWAY  MOVED-WRONG   uhdm-cmp pris -> pat
v194_a_explicit def     10        4       0        0         31/1 ->   0/0  CMP_EQUAL
v194_a_explicit elab    40        8       0        0         31/1 -> 442/1  head object CHANGED
v194_b_faces    def     16       16       0        0       4480/1 -> 4512/1 same head object
v194_b_faces    elab    44       32       0        0       4968/1 -> 5000/1 same head object
v194_c_views    def     14        8       0        0         31/1 -> 803/1  head object CHANGED
v194_c_views    elab    48       16       0        0         31/1 -> 903/1  head object CHANGED
v194_d_scopes   def   (33 cells, EXACT MATCH on BOTH binaries)   0/0 -> 0/0  CMP_EQUAL both
v194_d_scopes   elab  (81 cells, EXACT MATCH on BOTH binaries)   0/0 -> 0/0  CMP_EQUAL both
v194_e_explclone def     8        4       0        0         31/1 ->   0/0  CMP_EQUAL
v194_e_explclone elab   18        8       0        0         31/1 ->   0/0  CMP_EQUAL
                              TOTAL TO-GOLDEN 96,  AWAY 0,  MOVED-WRONG 0
```

**A cmp count going UP is not a regression here and it is PROVED, not asserted:**
the order-blind whole-dump diff of each arm's two databases is *pure addition*
(`a_explicit def` +4 lines, `elab` +8; `b_faces` +16/+32; `c_views` +8/+16 —
`REMOVED=0` everywhere, every added line a `vpiActual:` marker or the
`bit_select` it names). The objects the new heads sit on are therefore
BIT-IDENTICAL in both databases, so those defects are **pre-existing and merely
UNMASKED** by clearing the earlier head.

### `v194_a_explicit` — the fence-width question, ASKED AND ANSWERED

`pkgImportCloneTfs16` (the 194 fence) is populated ONLY under
`pkgImportCloneEmit` — the **WILDCARD** clone (`TaskFuncEmit.cpp:6682`;
`StmtEmit.cpp:3383` says so in as many words). The sibling fence one function
away in `endSelTrack` (§ `localBlockStmtSelBinds122`, `StmtEmit.cpp:417`) is the
BROADER `pkgImportCloneEmit || importCloneEmit || importCopyTsInst`. If an
EXPLICIT-import clone of an out-of-body method could reach § 37, the exemption
would fire on a listing the § 122 half fences out.

**It cannot.** Golden and both binaries agree: an explicit `import p::C;`
produces **no package-level clone listing of the out-of-body method at all** —
there is not one `va194_expl` row in any of the three censuses. The wildcard
control in the same file behaves exactly as the pass documented (golden NULL,
patched NULL, 4 cells). Arm E then re-asks it for an explicitly imported class
with an IN-BODY select, for an `export`ing middle package, and for a package
that holds BOTH import forms of the same home at once — **golden NULL, patched
NULL in every clone cell, and the arm is a 0/0 `CMP_EQUAL` exact match in both
views.**

### `v194_b_faces` — the emission faces, all TO-GOLDEN or all-agreeing

The patched DEF view is an **EXACT match with golden, 0 diff lines** (pristine
had 8 wrong cells):

| face | golden | pristine | patched |
|---|---|---|---|
| `b_read` — a pure **READ** of the return name, then the select write (2 refs) | `bit_select` | NULL | `bit_select` |
| `b_rec` — **RECURSION** + bit-select on a **PACKED** return (3 refs) | `bit_select` | NULL | `bit_select` |
| `b_two_st` — the return name's select is the block's **SECOND** select (2 refs) | `bit_select` | NULL | `bit_select` |
| `b_unp` — element select on an **UNPACKED-ARRAY** return | `bit_select` | NULL | `bit_select` |
| `b_memb` — **MEMBER select on a packed struct** return (2 refs) | NULL | NULL | NULL |
| `b_nest` — the select in an **INNER named block**, the whole refs outside (2 refs) | NULL | NULL | NULL |
| `b_void` — a **VOID function** | *no census row on any side* | — | — |
| `b_task` — a **TASK** | *no census row on any side* | — | — |

`CAND` = 24 on golden, pristine and patched: **the patch mints nothing, and
neither a void function nor a task gains a return object.**

### `v194_d_scopes` — the scope shapes, the strongest negative control

Seven out-of-body methods whose select sits in a scope our block model and
Surelog's could disagree about: a `for` body without `begin`, a `for` body's own
`begin`/`end`, a `while` body, a `case` arm without `begin`, a `case` arm's
`begin`/`end`, a nested anonymous `begin`, and a return name **selected only as
an RVALUE**. Golden leaves **every one of them NULL** in the package listing, and
**both binaries produce a 0-line / 0-head `CMP_EQUAL` against that golden in both
views** — the arm does not move at all. The exemption does not over-reach past
"the select is a direct statement of the reference's own block", which is what
`noteSelectObj`'s `selScopeStack.back().isBlock` gate and its `inLhs` guard
(`ExprEmit.cpp:27283`) encode and what Surelog's `Stmts()` scan requires.

### `v194_c_views` — views, shadowing, instances

The patched DEF view is again an **EXACT match with golden, all 18 cells**:

| cell | golden | pristine | patched |
|---|---|---|---|
| out-of-body `VC194::c_out`, home package listing | `bit_select` | NULL | `bit_select` |
| out-of-body `VCO194::o_out` in an **ORPHAN package nothing imports** | `bit_select` | NULL | `bit_select` |
| **IN-BODY** class method `c_in` with a direct select | NULL | NULL | NULL |
| class declared **inside a MODULE** (`m_in`) — § 37 never reaches it | NULL | NULL | NULL |
| a nested block's **LOCAL SHADOWING the function's own name**, and the select on the SHADOW | `byte_var:c_shadow` | `byte_var:c_shadow` | `byte_var:c_shadow` |
| the shadowing function's own return-name refs, package listing | NULL | NULL | NULL |

The shadow cell is the one Surelog decides by NAME and we decide by slang
`Symbol*`; both land on the inner `byte_var`, which is the `uhdmbegin` arm's
`Variables()` sub-arm answering **before** the `Stmts()` scan — visible verbatim
at `UhdmWriter.cpp:3551-3560`. Three module instances change nothing.

## 5. GATES — ALL GREEN, RUN HERE

* build both, `-j 2`, md5s above; goldens **23/0** patched, **23/0** pristine,
  `SLANG_UHDM=/bin/false` **0/23**;
* every `cmds.txt` audited by binary PATH (1523+1523 surelog, 1458+1458 u2r);
* u2r `default` + `testflags`: three `ct8rows` **PASS** (0 differing rows, status
  AND dump column), byteverify **0 movers / 1358**, SELFCHECK 1357/1358,
  canaries `ok=8 changed=0`, `ctcan2` **PASS**;
* surelog both modes, 1588 rows: **2 differing rows, both the conversion above**;
  pristine-vs-baseline `PASS: every row byte-identical`; byteverify **2 / 956**
  both PREDICTED BY NAME, SELFCHECK 955/956, each attributed **ADDED=4 REMOVED=0
  UNATTRIBUTED=0**;
* canaries surelog `ok=52 changed=0` pristine, `ok=50 changed=2` patched with
  the two CHANGED rows printed as the conversion; `ctcan2` **PASS** on both;
  `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0**;
* protected databases: InterfaceModPort `59a365f3ce2c`, BlackParrotComplex
  `e3e354129d5a`/`73a10e8217e5`, YosysOldOr `d68e0796d62c` — identical on both
  binaries; **SVSwitch `4842211c4030` HELD**, **YosysVerx `6ccda350c24a` HELD**;
* heads: BuildUVMPkg **31/1 → 0/0** both modes; SeqDriver, SimpleUVM, Scoreboard,
  MiniAmiq, Earlgrey_0_1 and Rggen `.cmp` output **byte-identical** pristine vs
  patched (`cmp -s`, not a line count);
* the wide boundary over a COPY of the whole probe tree, **5163 arms** (the pass's
  5159 plus this verification's 4 at the time it ran) in both views with every rc
  recorded:

```
LISTED=5163 PROCESSED=5163 PRODUCED_DBS=4998 MOVED_ARMS=8 RC_DIFFS=0
```

  All 8 accounted for: 3 are the pass's own `grid194/g194_*.sv`, 3 are this
  verification's own arms (both POSITIVE CONTROLS — a gate that moved nothing
  over them could not see), and 2 are r10uvm171's home grids, re-measured against
  their own real Surelog goldens in both views at **TO-GOLDEN 6 / AWAY 0 /
  MOVED-WRONG 0** each. **`RC_DIFFS=0`**: the `--elabuhdm` segfaults the driver
  prints occur on BOTH binaries for the same arms, so no rc pair differs.
  **THE FLOOR IS UNTOUCHED, BY NAME:** no arm of uvm184 / v184 (§
  `retNameArgKeepsReturnVar184v` and the receiver-kind fence), uvm185, uvm186 /
  v186, uvm187, uvm188, uvm189, uvm190, uvm191 / v191, uvm192 (§
  `pkgTfBodyCmViewClone192`), uvm82-91, buvm3-15 or sd8-12 appears in the mover
  list. `r10uvm171repro/g171_b_homes.sv` — the arm r10uvm171's README recorded as
  *"a PRE-EXISTING, unrelated defect on the OUT-OF-BODY class method"* — goes
  **31/1 → 0/0 `CMP_EQUAL`** in both views.

## 6. RESIDUES, RANKED

* **RV-1 (latent, not reachable today) — the fence is NARROWER than its sibling.**
  § 194 fences on `pkgImportCloneTfs16` (WILDCARD clones only) while
  § `localBlockStmtSelBinds122`, which shares the producer, fences on
  `pkgImportCloneEmit || importCloneEmit || importCopyTsInst`. Arms A and E show
  no explicit-import path currently produces a package-listed clone of an
  out-of-body class method, so the gap has no reach — but a future pass that
  makes `importCloneEmit` mint such a listing must widen this fence in the same
  commit. Cheap insurance; deliberately NOT changed here, because widening it
  today would be an unmeasured edit to a green law.
* **RV-2 = the pass's R1, CONFIRMED PRE-EXISTING.** `part_select` /
  `indexed_part_select` on a return name never reach `funcRetSelBound`. Measured
  on the implementer's own `b_kinds`: golden binds the select in BOTH listings,
  and the **CLASS listing is wrong on the PRISTINE binary too**
  (`ACT=bit_var:b_part@24:12` where golden has `part_select:b_part@27:5`), which
  is what makes it a residue rather than a regression. `STILL-EXTRA 4 /
  STILL-MISSING 4`, identical on both binaries, in both views.
* **RV-3 = the pass's R2, CONFIRMED PRE-EXISTING AND WIDER THAN REPORTED.** An
  import clone of a package FREE function takes the SELECT where golden takes the
  home `Return` (`string_var`). Arm A shows it on the **EXPLICIT** clone
  (`va194_explf::va_free`, 4 DEF cells) as well as the wildcard one — **identical
  on both binaries**, so the patch neither causes nor widens it. It is the head
  arm A's ELAB view now stops on.
* **RV-4 — three fresh, one-file heads this verification unmasked**, each
  reproducible from a single committed arm and each proved pre-existing by an
  additions-only whole-dump diff: `v194_c_views` def/elab stops on a
  `class_defn (work@vc194_wrap::VCM194)` **method-vector** mismatch on a
  module-scope class; `v194_a_explicit` elab stops on `function
  (va194_explf::va_free)`; `v194_b_faces` keeps its `package (vb194_src)` head on
  both binaries.

## 7. THE FILES

| file | what it is |
|---|---|
| `grid194v/v194_a_explicit.sv` | the EXPLICIT-import clone axis, with the wildcard control in the same file |
| `grid194v/v194_b_faces.sv` | read-vs-write, recursion, packed / unpacked / struct returns, member select, inner-block select, void function, task |
| `grid194v/v194_c_views.sv` | in-body vs out-of-body, an ORPHAN package, a class inside a module, a LOCAL shadowing the function name, three instances |
| `grid194v/v194_d_scopes.sv` | `for` / `for`+`begin` / `while` / `case` / `case`+`begin` / nested `begin` / RVALUE-only — the scope negative controls |
| `grid194v/v194_e_explclone.sv` | explicit import of a class with an in-body select, an `export`ing middle package, and both import forms of one home at once |
| `grid194v.sh` `scoregrid194v.sh` `score194.py` `ct194cen.cpp` | the arm driver, its scorer and the census instrument, copied unmodified from `r10uvm194repro` so the two sides are scored by the SAME code |
| `GATES.r10v194.txt` `ARMS.r10v194.txt` `BOUNDARY.r10v194.txt` `OWNER.r10v194.txt` | the transcripts |

## 8. REPRODUCING

```sh
# instruments (measurement only)
../r10uvm194repro/build194.sh /tmp/v194_bin

# one arm: one REAL Surelog golden, both binaries, both views, every rc recorded
CEN=/tmp/v194_bin/ct194cen ./grid194v.sh grid194v/v194_b_faces.sv <pristine> <patched> <wd>
./scoregrid194v.sh <wd> b_faces

# the additions-only proof for any arm (the test that separates an UNMASKED
# pre-existing head from a caused one): a sorted whole-dump diff must be
# ADDED=n REMOVED=0, every added line a `vpiActual:` or the select it names
uhdm-dump <wd>/a_def.uhdm | sed 's#<wd>##g;s/id:[0-9]*//g' | sort > A
uhdm-dump <wd>/b_def.uhdm | sed 's#<wd>##g;s/id:[0-9]*//g' | sort > B
diff A B

# the corpus gates (from ../r10uvm194repro, whose copies of byteverify.sh /
# ct8rows.sh / canaries.sh / ctcan2.sh / rowheads.sh are byte-identical to the
# canonical r10oth4repro / r10oth8repro / r10uvm52repro / r10uvm67repro ones —
# checked here with `diff -q`)
./ct8rows.sh results/golden_surelog.csv <fresh sweep>.csv
SELFCHECK=1 ./byteverify.sh <patched wd> <pristine wd>
./attrib194.sh <patched wd> <pristine wd> <outdir> <rel...>
PRIS=… PATCHED=… ./bound194.sh <copy of tools/probe> <outdir>
```
