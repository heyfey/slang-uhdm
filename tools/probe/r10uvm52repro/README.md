# r10uvm52 — the RECEIVER-QUALIFIED call argument. ONE law, the head moved on FIVE rows, NO conversion

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order. Every dump excerpt is passed through `sed 's#/home/[^ ,]*/##g'` and
`sed '1d'` (uhdm-dump's first line is the DATABASE PATH).

Base **edfde51**. My worktree's control build of pristine edfde51 came out
`md5 3cb9e2dc7ced2256cccb28a620fc774f`, **byte-identical to the main-tree
`build/slang-uhdm` at the start of this pass**, which independently validates it
as the HEAD control. Final build: `62b525a3864d8ac4b0417b868b0f63ef`.
(The main-tree binary was `3479e2d10a75171848cf3aa83498d65a` two hours later —
the other slot rebuilt it — so it is NOT usable as a control at gate time; the
HEAD control was rebuilt HERE from edfde51 sources, §8.)

## 0. HEADLINE — honest

* **NOTHING CONVERTED.** `SimpleUVM`, `SeqDriver`, `Scoreboard` and
  `BuildUVMPkg` are still `CMP_NOTEQUAL`. **No row in either committed baseline
  changed. There is NO CONVERSION to promote.**
* **ONE law landed: `classInBodyRecvCallArgNoBind52`** (3 sites, all tagged
  `NOTE § classInBodyRecvCallArgNoBind52` in the code). Direction: **SUPPRESS**.
* **The head of the five-row group MOVED to a new family.** Target 1 is
  finished as far as `uhdm-cmp` can see it on those rows.
* **THE BRIEF'S DISTINGUISHER IS REFUTED, and so is my own first replacement.**
  "Inside a CLASS METHOD a call-argument `ref_obj` carries NO `vpiActual`;
  inside a PACKAGE SUBROUTINE it DOES" is false: golden binds **2402**
  `vpiArgument` ref_objs to io_decls inside `class_defn` methods in the very
  database the brief cites (§1). The real axis is **IN-BODY vs OUT-OF-BODY**
  plus **receiver-qualified vs bare** plus **statement vs not** (§3).
* **TARGET 2 IS HONESTLY NOT DONE** — but its open question is now ANSWERED as a
  measurement (§6): pass 50 said "neither source order nor name order can pick
  that base"; the key nobody had tried is the **SPECIALIZATION** name, and it
  picks golden's base exactly.
* Reach, measured on SimpleUVM's own golden with the instruments shipped here
  (`dumptree.py` + `bindiff.py`), joining **25181** paired `ref_obj` identities:

  | binary | AGREE | DIFFER |
  |---|---|---|
  | edfde51 control `3cb9e2dc` | 24738 | **443** |
  | final `62b525a3` | 24840 | **341** |

  **102 disagreements removed and ZERO added** — every bucket in the post
  histogram is smaller than or equal to its pre counterpart, none is larger
  (§4). That is the reach statement this pass can make.

## 1. THE BRIEF'S CENTRAL CLAIM IS REFUTED — with the instrument that shows it

The brief said, of the head at uvm-1.2 `base/uvm_pool.svh:87`:

> *"inside a CLASS METHOD a call-argument `ref_obj` carries NO `vpiActual`;
> inside a PACKAGE SUBROUTINE it DOES."*

**Measured on the same database the brief measured, and it is not true.**
`dumptree.py … boundby io_decl` on SimpleUVM/`default`'s golden:

```
ref_obj -> vpiActual -> io_decl : 6911 total          (the brief's 6911, reproduced)
RELATION               SUB CONTAINER  COUNT
vpiArgument            class_defn     2402      <-- the claim says this is 0
vpiArgument            package        1221
vpiOperand             class_defn     1072
…
```

Two of golden's own class-method call arguments, the same shape as the head:

| site | source | LHS golden |
|---|---|---|
| `uvm_default_factory::set_type_override_by_name` `m_type_names.exists(original_type_name)` | uvm_factory.svh:1006 | **BOUND** -> io_decl |
| `uvm_component::get_child` `m_children.exists(name)` | uvm_component.svh:1884 | **BOUND** -> io_decl |
| `uvm_pool::get` `pool.exists(key)` | uvm_pool.svh:87 | **BARE** — the head |

So a blanket class-method gate would have removed **2402** correct bindings.

### 1a. A MEASUREMENT DEFECT I MADE AND CAUGHT — recorded so nobody repeats it

My **first** grid said golden binds ZERO class-method hier-path arguments, which
looked like a clean confirmation of the brief. It was an instrument bug.
`uhdm-dump` prints the same class body in more than one tree position, and in
some of them the enclosing `class_defn` appears only as a `vpiParent`
BACK-EDGE (which the parser correctly drops), so the nearest surviving container
ancestor is the **package**. Keying the join on (loc, name, relation,
subroutine) alone let the package-labelled copy overwrite the class_defn one.
`bindiff.py` now keeps the most specific container, and its `--selftest` carries
a **duplicate-printing control cell** that fails if the fix is removed. Both
grids in §3 are from the corrected instrument.

## 2. Drivers and arms (all committed here, all with working guards)

| asset | what it is |
|---|---|
| `dumptree.py` | **new** — parses a uhdm-dump into a real tree (dropping `vpiParent` back-edges) so "which RELATION holds this ref_obj, in which SUBROUTINE, in which CONTAINER" is a measurement. Commands: `boundby`, `actualkinds`, `refs`, `reftab`, `hpargs`. GUARDS: refuses to report on a file it parsed to 0 nodes; prints `UNMEASURED` for an empty result; **`--selftest`** parses a built-in fixture and asserts the relation/ancestor/back-edge answers (the positive control). |
| `bindiff.py` | **new** — joins golden's and our `reftab`s and prints every ref_obj whose `vpiActual` disagrees, plus `--ctxcensus <rel> <container>`, THE PREDICATE GRID. The join key is deliberately NOT the fullname (golden spells a hier-path argument `<sub>::<path>::<arg>`, we spell `<sub>::<arg>`). GUARDS: hard error if either side loaded 0 rows; prints the UNPAIRED counts on both sides; **`--selftest`** asserts 4 paired / 1 differ / 1 unpaired each side AND the duplicate-printing container control of §1a. |
| `gold.sh` | one arm: golden + ours, dump + cmp + content ±. Copied from `r10uvm51repro` with the `sed '1d'` fix intact. Guards: both databases existence-checked before cmp (uhdm-cmp EXITS 0 on a MISSING input); slang path + md5 printed every run. |
| `heads.sh` | per-test cmp lines / head count / id-normalised head md5 over a workdir; reports `SKIP-NOFILE` and counts it. **Header corrected** — it iterates the WHOLE workdir, not "the UVM-4" (pass-51 integration item 5), and now says the md5 is instrument-local. |
| `corpdump.sh` | both sides of one CORPUS test out of a `verify_golden` workdir. |
| `csvdiff.py` | WHOLE-ROW diff (status AND dump) of a sweep CSV against a committed baseline. Row counts from the parsed dict, never `wc -l`. |
| `manifest.sh` / `bvcompare.sh` | the byte verifier's two halves. Both refuse to report on an empty manifest / an empty join. **`bvcompare.sh`'s Scoreboard label FIXED** — the misleading `[NOT EVIDENCE]` text flagged by the pass-50 AND pass-51 integrations now reads "TARGET, and also KNOWN-NONDETERMINISTIC". |
| `canaries.sh` | per-NAME canary check; prints ABSENT and counts it. |
| `explainmover.sh` | HEAD-vs-POST dump diff for one mover. |
| `a1/dut.sv` | **new** — 9 cells: built-in `exists` on a concrete assoc array / on a TYPE-PARAMETER-indexed array / user method via a plain-class handle / via a generic-specialization handle, each inside a PLAIN and a GENERIC class, plus the package controls and a non-call control. |
| `a2/dut.sv` | **new** — **THE DECIDER**: the same three bodies written IN BODY (`ib52`), OUT OF BODY (`ob52`) and as a PACKAGE function (`pk_all`), crossed with STATEMENT / if-CONDITION / r-value position and bare / handle / built-in callee. |

Every arm is judged on `diff -u g.dump o.dump` (via `dumptree.py`), never on cmp
alone — `a1`'s cmp head never moved in this pass (it is residue R4) while three
of its cells were fixed, which is exactly the m_visited trap in the flesh.

## 3. THE LAW — `classInBodyRecvCallArgNoBind52`

**Predicate** (`include/UhdmExporter.h`, `grep -n 'int recvCallArgDepth52'`;
gate at `src/ExprEmit.cpp`, `grep -n 'bool recvCallArgNoBind52'`):

> `curSubClassScope9 && !curSubOob9 && recvCallArgDepth52 > 0`

i.e. **an IN-BODY class method, inside the ARGUMENT LIST of a
RECEIVER-QUALIFIED call in EXPRESSION position.** `recvCallArgDepth52` is a
counter raised by the RAII `RecvCallArg52` (`grep -n 'struct RecvCallArg52'`) at
the three `!callStmtCtx0` `hier_path` arms of the Call case — STATEMENT position
never takes the hier_path shape in our emitter, so the statement half of the
gate needs no test of its own.

**Direction: SUPPRESS** (the reference takes no actual of any kind; the object
is still emitted, only its `vpiActual` is withheld).

**Why `curSubClassScope9` and not `classMethodNoBind`:** an if/case CONDITION
clears `classMethodNoBind` mid-body (the carve-out documented beside it), and
the corpus head IS a condition — `if (!pool.exists(key))`. This is the same
reason `§ controlBodyNoBind28` one line above uses the stable flag.

**Three sites, all tagged `NOTE § classInBodyRecvCallArgNoBind52`:**

| site | file / arm | what it serves | arm cell |
|---|---|---|---|
| 1 | `src/ExprEmit.cpp`, the `!callStmtCtx0 && recv0.kind == NamedValue` arm (`grep -n 'RecvCallArg52 rca52('`) | ONE-NAME-receiver CLASS-METHOD call in expression position | a2 `ib_cond_hnd_formal`, a1 c4/c5/c6 |
| 2 | `src/ExprEmit.cpp`, the dotted-path arm (`grep -n 'RecvCallArg52 rca52H'`) | `a.b.m(x)` in expression position | (no cell fired; kept for symmetry, see §7 R3) |
| 3 | `src/ExprEmit.cpp`, the built-in-method hier_path arm (`grep -n 'RecvCallArg52 rca52B'`) | **THE CORPUS HEAD'S SITE** — built-in method on a receiver | a2 `ib_cond_builtin_formal`, a1 c1/c2/c3 |

### ARM a2 — THE PREDICATE GRID, every cell, BOTH SIDES, ONE golden

`tools/probe/r10uvm52repro/a2/dut.sv`. The three bodies are written three times:
inside the class (`ib52`), after `endclass` (`ob52`), and as a package function
(`pk_all`). Every cell name below is a comment in that file at the cited line.

| cell | source (line) | position / callee | LHS golden | RHS edfde51 | RHS final |
|---|---|---|---|---|---|
| `ib_stmt_bare_formal` | 54 `bare52(f);` | STATEMENT, bare | io_decl | io_decl | **io_decl — unmoved** |
| `ib_stmt_bare_local` | 55 `bare52(loc);` | STATEMENT, bare | int_var | int_var | **int_var — unmoved** |
| `ib_stmt_bare_prop` | 56 `bare52(prop);` | STATEMENT, class PROPERTY arg | NONE | NONE | **NONE — unmoved** |
| `ib_stmt_hnd_formal` | 57 `h.ut52(f);` | STATEMENT, RECEIVER | io_decl | io_decl | **io_decl — unmoved** |
| `ib_cond_builtin_formal` | 62 `if (amap.exists(k))` | if-COND, RECEIVER built-in | **NONE** | io_decl | **NONE — FIXED** |
| `ib_cond_bare_formal` | 64 `if (bare52(f) == 0)` | if-COND, bare | io_decl | io_decl | **io_decl — unmoved** |
| `ib_cond_hnd_formal` | 66 `if (h.um52(f) == 0)` | if-COND, RECEIVER user | **NONE** | io_decl | **NONE — FIXED** |
| `ib_rval_bare_formal` | 74 `loc = bare52(f);` | r-value, bare | **NONE** | io_decl | io_decl — **STILL WRONG, residue R2** |
| `ib_rval_hnd_formal` | 75 `loc = h.um52(f);` | r-value, RECEIVER | NONE | NONE | **NONE — unmoved** |
| `ob_stmt_bare_formal` | 92 | OUT OF BODY, statement | io_decl | io_decl | **io_decl — unmoved** |
| `ob_stmt_bare_local` | 93 | OUT OF BODY | int_var | int_var | **int_var** |
| `ob_stmt_bare_prop` | 94 | OUT OF BODY, property | logic_net (class view) / NONE (pkg view) | same | **same** |
| `ob_stmt_hnd_formal` | 95 | OUT OF BODY, receiver stmt | io_decl | io_decl | **io_decl** |
| `ob_cond_builtin_formal` | 99 `if (amap.exists(k))` | **OUT OF BODY, if-COND, receiver** | **io_decl** | io_decl | **io_decl — UNTOUCHED** |
| `ob_cond_bare_formal` | 101 | OUT OF BODY | io_decl | io_decl | **io_decl** |
| `ob_cond_hnd_formal` | 103 `if (h.um52(f) == 0)` | **OUT OF BODY, if-COND, receiver** | **io_decl** | io_decl | **io_decl — UNTOUCHED** |
| `ob_rval_bare_formal` | 110 | OUT OF BODY, r-value | io_decl | io_decl | **io_decl** |
| `ob_rval_hnd_formal` | 111 | OUT OF BODY, r-value, receiver | io_decl | io_decl | **io_decl** |
| `pk_*` (all seven) | 122–129 | PACKAGE function | io_decl | io_decl | **io_decl — UNTOUCHED** |

**Rows 99 and 103 are the whole reason the gate carries `!curSubOob9`.** They are
BYTE-FOR-BYTE the same source as rows 62 and 66, moved after `endclass`, and
golden binds them. An implementer who gated on "class method" alone would have
broken them, and the arm would have said so.

**HOW THE GATE WAS PROVED NECESSARY.** Two ways. (a) The arm: exactly the two
cells golden leaves bare moved, and the seventeen others did not. (b) The
corpus: SimpleUVM's ref_obj disagreements went **443 -> 341** with **zero new
disagreements** (§4), and the five-row head left this family (§5).

### ARM a1 — the receiver-shape sweep, BOTH SIDES

`tools/probe/r10uvm52repro/a1/dut.sv`, read with `dumptree.py … hpargs`.

| cell | source | shape | LHS golden | RHS edfde51 | RHS final |
|---|---|---|---|---|---|
| c2 | 47 `cmap.exists(k)` in a GENERIC class | built-in, concrete index | NONE | io_decl | **NONE — FIXED** |
| c3 | 54 `pool.exists(k)`, index = TYPE PARAM | built-in — **corpus-head shape** | NONE | io_decl | **NONE — FIXED** |
| c1 | 70 `pmap.exists(k)` in a PLAIN class | built-in, concrete index | NONE | io_decl | **NONE — FIXED** |
| c6 | 60 `uh.m52(v)` in a generic class | user method via handle | NONE | NONE | NONE |
| c4 | 76 `ph.m52(v)` in a plain class | user method via handle | NONE | NONE | NONE |
| c5 | 80 `gh.c2_concrete(k,1)` | via a GENERIC-specialization handle | NONE | NONE | NONE |
| c8 | 95 `lh.m52(v)` in a PACKAGE function | the control | **io_decl** | io_decl | **io_decl — UNTOUCHED** |

a1's dump content ± fell **217 -> 211**; its `cmp` stayed 18 lines / 1 head
throughout, because a1's head is residue **R4** (`vpiSigned` placement), not this
family. **Judged on the dump, never on cmp.**

**REFUTATION recorded — GENERIC-ness is NOT the axis.** a1 c1 (plain class) and
a1 c2/c3 (generic class) behave identically in golden, and so do c4/c6. The
uvm_pool witness being a generic class is a coincidence of which class the head
landed in; the axes are in-body/out-of-body, receiver/bare, statement/not.

## 4. REACH ON THE CORPUS — the number that matters

`dumptree.py … reftab` on both sides, joined by `bindiff.py`
(SimpleUVM/`default`, golden from the shared cache, ours from my own sweeps):

```
edfde51 3cb9e2dc  PAIRED 25181  AGREE 24738  DIFFER 443
final   62b525a3  PAIRED 25181  AGREE 24840  DIFFER 341
```

Per-bucket, and **nothing grew**:

| relation / container | LHS golden | RHS ours | edfde51 | final |
|---|---|---|---|---|
| vpiArgument / class_defn | NONE | io_decl | **97** | **37** |
| vpiArgument / class_defn | NONE | string_var | **34** | **13** |
| vpiArgument / class_defn | NONE | class_var | **21** | **8** |
| vpiArgument / class_defn | NONE | enum_var | **4** | **0** |
| vpiArgument / class_defn | NONE | array_var | **3** | **0** |
| vpiArgument / class_defn | NONE | int_var | **3** | **2** |
| every other bucket | | | unchanged | unchanged |

The 37 io_decl over-binds that remain are the ones this law does not reach:
r-value BARE calls (a2 `ib_rval_bare_formal`, residue R2) and shapes our emitter
does not render as a hier_path.

**Proof the code RAN and where:** the three RAII sites are the only writers of
`recvCallArgDepth52`, the arm cells at a2:62/a2:66 and a1:47/54/70 moved from
`io_decl` to `NONE`, and 102 corpus rows moved with them. A fix that reached
nothing would have left 443.

## 5. WHERE THE HEAD IS NOW — measured per row with `heads.sh`

| test | mode | HEAD (edfde51) lines/heads | POST lines/heads | POST head family |
|---|---|---|---|---|
| SimpleUVM | default | 29 / 1 | **81 / 1** | NEW — `class_typespec (uvm_set_before_get_dap)` |
| SimpleUVM | testflags | 29 / 1 | **81 / 1** | same |
| SeqDriver | default | 29 / 1 | **81 / 1** | same |
| SeqDriver | testflags | 29 / 1 | **81 / 1** | same |
| Scoreboard | default | 29 / 1 | **81 / 1** | same |
| BuildUVMPkg | default | 17 / 1 | **17 / 1** | UNCHANGED — target 2 |
| BuildUVMPkg | testflags | 17 / 1 | **17 / 1** | UNCHANGED — target 2 |
| Scoreboard | testflags | SKIP-NOFILE (SLANG_REJECT at baseline) | SKIP-NOFILE | — |

The three uvm-1.2 tests still share ONE head with each other (their normalised
head md5s are EQUAL — I quote the equality, not the number, because pass 51's
integration proved that number is instrument-local), and it is a **new family**:

```
LHS: <null>
RHS: class_typespec: (uvm_set_before_get_dap), line:58:10, endln:58:54
     |vpiParent: class_var (uvm_pkg::uvm_tr_stream::m_cfg_dap)
     |vpiParameter:   type_parameter (uvm_set_before_get_dap.T)
     |vpiParamAssign: param_assign
```

against golden's own object for the same declaration
(`g.dump:897401`, `uvm_tr_stream.svh:58`
`uvm_set_before_get_dap#(m_uvm_tr_stream_cfg) m_cfg_dap;`):

| field | LHS golden | RHS ours |
|---|---|---|
| span | `58:10, endln:58:32` — the GENERIC CLASS NAME token | `58:10, endln:58:54` — the WHOLE `uvm_set_before_get_dap#(m_uvm_tr_stream_cfg)` |
| vpiParameter / vpiParamAssign | **none / none** | 1 / 1 |

That is pass-50 law 3's LISTING SHAPE (name-token span, no parameters) applied to
a class VARIABLE of a specialization rather than to a typedef. Residue **R1**.

## 6. TARGET 2 — HONESTLY NOT DONE, but its open question is ANSWERED

`BuildUVMPkg`'s head is unchanged from pass 51 and is pass-50's residue R2,
`classNestedClassTdGroupWithoutPkgAnchor`. The fix ADDS:

```
LHS: ref_typespec (uvm_pkg::uvm_pool::type_id)
       vpiParent  class_typespec (type_id) @26247:12-26247:31
       vpiActual  class_typespec (type_id) @26247:12-26247:31   (a DIFFERENT object)
RHS: <null>
```

(1800.2-2017-1.0 pp lines — BuildUVMPkg compiles 1800.2 while the other three
compile uvm-1.2; the two versions' line numbers are not interchangeable.)

**Pass 50's open question, quoted:** *"26247 is not the lowest line among the
`type_id` typedefs (uvm_pool's own is 14284) and all group members share the name
`type_id`, so neither source order nor name order can pick this base — the
unmeasured half is Surelog's class COMPILE order."*

**MEASURED, and it is not compile order — it is NAME ORDER OF THE
SPECIALIZATION.** `grep -n "typedef uvm_object_registry#" ` on
`1800.2-2017-1.0/pp_output/uvm_pkg.sv` gives 50 members. Line 26247 is
`typedef uvm_object_registry#(uvm_barrier,"uvm_barrier") type_id;`, and
**`uvm_barrier` is alphabetically FIRST** among every concrete specialization in
the group (`uvm_barrier` < `uvm_callback` < `uvm_cause_effect_link` <
`uvm_comparer` < `uvm_copier` < `uvm_field_op` < `uvm_line_printer` < …). The
one earlier member by source order, line 16779
`typedef uvm_object_registry#(this_type) type_id;`, sits inside the GENERIC class
`uvm_resource #(type T=int)` (pp:16767) and is not a concrete specialization at
all.

So pass 49/50's law is intact and only its KEY was too narrow: **the base of a
shared generic-class typedef group is picked by NAME ORDER — of the TYPEDEF name
where those differ, and of the SPECIALIZATION where (as here) every member is
called `type_id`.** That is a checkable prediction the next pass can implement
against, and it costs nothing to re-verify: it is one `grep` and one `sort`.

**I did not implement it.** It needs `classTdGroupBase50` to be populated from
class-NESTED typedefs when no package-level anchor exists, which changes the span
and the parameter lists of class_typespecs across both corpora, and the gate
budget left in this pass would not have covered the collateral. Residue **R5**,
and it is the only thing between here and `BuildUVMPkg`'s two rows.

## 7. RANKED RESIDUE — most reachable first

**R1. `classVarSpecializationListingShape52` — a class VARIABLE declared of a
GENERIC-CLASS SPECIALIZATION gets the listing shape: span = the generic class
NAME TOKEN, no `vpiParameter`, no `vpiParamAssign`. DIRECTION: RESHAPE. Depth:
medium (pass-50 law 3 already builds this shape for typedefs; this is the
declaration-site twin). RANK 1 — it is the LIVE head of FIVE rows.** Witness in
§5, both sides, `uvm_tr_stream::m_cfg_dap` at `uvm_tr_stream.svh:58`
(golden `58:10-58:32`, ours `58:10-58:54`). Expect a further head behind it.

**R2. `classInBodyRvalBareCallArgNoBind` — a BARE call's argument in an
IN-BODY class method in R-VALUE position. DIRECTION: SUPPRESS. Depth: SHALLOW
(one more `RecvCallArg52`-style window, at the bare `func_call` arm, gated on
`!callStmtCtx0`). RANK 2.** Measured in a2 both sides: `loc = bare52(f);`
(line 74) is golden NONE / ours io_decl, while the STATEMENT twin (line 54) and
the if-CONDITION twin (line 64) are BOTH bound in golden. So the bare-call
window is STATEMENT-and-CONDITION only, and § classArgBind12's comment
("`sink(f)` binds") has an unmeasured half: it never saw the r-value spelling.
Accounts for part of the 37 remaining corpus over-binds. I did not do it because
the a2 cell is polluted — Surelog reports `CP0332 Function "bare52" is not
defined for variable "this"` for the STATEMENT spellings (LAW C), so the r-value
half deserves its own clean arm first.

**R3. SITE 2 IS UNWITNESSED. DIRECTION: n/a. RANK 3 (a hole in this pass, not a
defect).** The dotted-path arm (`rca52H`) carries the law by symmetry with sites
1 and 3, but NO arm cell and NO corpus row was shown to change through it. It is
in the patch because leaving one of three structurally identical arms ungated is
the "law that only ever saw one spelling" trap; it is recorded here as
UNMEASURED rather than claimed.

**R4. `assocArrayVarCarriesElemSign` — golden puts `vpiSigned` on the array_var
of a signed-element assoc/queue/dyn array, we put it on the element reg.
DIRECTION: MOVE. Depth: shallow per site. RANK 4, and it is STILL the head of
arm a1.** Pre-existing at edfde51, untouched by this pass, cmp-visible
(`variables::Compare` reads `VpiSigned`). The brief's census of 479 declarations
was NOT re-measured here. **It has NOT become a corpus-row head after this
pass's law** — the five rows' head is R1 and BuildUVMPkg's is R5.

**R5. `classNestedClassTdGroupWithoutPkgAnchor` — §6. DIRECTION: ADD. Depth:
medium. RANK 5, and it is the head of BuildUVMPkg's TWO rows.** HONESTLY NOT
DONE. Its one open question is now answered (§6): base = alphabetically first
SPECIALIZATION name, `uvm_barrier`'s `type_id` at pp 26247.

**R6. the `LHSgolden=BOUND / RHSours=NONE` half — 100+ UNDER-binds this pass did
not touch. DIRECTION: ADD. Depth: unknown. RANK 6.** `bindiff.py` reports them
beside the over-binds: `vpiOperand class_defn golden=class_var ours=NONE` x17,
`vpiArgument class_defn golden=class_var ours=NONE` x16, `golden=string_var
ours=NONE` x14, `golden=parameter ours=constant` x12. They are unchanged by this
pass in both directions. Whoever takes them has the instrument already.

## 8. Gates — every one, with the numbers I measured

Binary md5 printed BEFORE and AFTER every sweep; **no rebuild happened while a
sweep was running**. `git stash` was never used.
`results/gate_uhdm2rtlil.csv` and `results/golden_surelog.csv` were **read only,
never rebuilt, edited or included.** Their row counts come from the parsed dict
(731 and 1588), never from `wc -l` (732 and 1589 with the header).

| gate | result |
|---|---|
| 1. `cmake --build build -j 3`, my own worktree | rc 0, `62b525a3864d8ac4b0417b868b0f63ef` (control `3cb9e2dc7ced2256cccb28a620fc774f` — **the md5 CHANGED**) |
| 2. 23 goldens, `SLANG_UHDM` exported to MY build | **PASS 23 / FAIL 0** |
| 2b. negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** — the harness really is using the exported binary |
| 3. uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir` | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496 match / 183 differ / 52 blank**; `csvdiff.py` vs `results/gate_uhdm2rtlil.csv`: **ROW DIFFS 0** |
| 4. surelog, `--mode both --jobs 2`, own `--out`/`--workdir` | see §9 |
| 5. byte verifier, BOTH corpora, same workdir paths | see §10 |

**THE GATED BINARY IS THE SHIPPED SOURCE.** After gating I corrected one factual
error in my own code comment (see "Corrections I made to my own work" below) and
rebuilt; the rebuild came out `62b525a3864d8ac4b0417b868b0f63ef` — **the same
md5** — so every gate below ran on a binary byte-identical to the one this patch
produces.

## 9. GATE 4 — the surelog corpus

`--mode both --jobs 2`, `--out /tmp/r10uvm52_sl.csv`,
`--workdir /tmp/r10uvm52_sl_wd`, `SLANG_UHDM` exported to my build; md5
`62b525a3` printed before AND after.

* `default` **467 CMP_EQUAL / 13 CMP_NOTEQUAL**, `testflags` **463 / 10**.
* totals **930 CMP_EQUAL / 23 CMP_NOTEQUAL / 570 SLANG_REJECT / 48 SURELOG_FAIL
  / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM**.
* dump **390 match / 540 differ / 658 blank** — **the match counts did not
  fall** (baseline 390: 225 default + 165 testflags).
* `csvdiff.py` vs `results/golden_surelog.csv`: **ROW DIFFS 0**.
* No `Google,testflags` SURELOG_FAIL-vs-TIMEOUT flake this run (it would have
  shown as a row diff; there were none).
* `LowMemPkg,testflags`' baseline row carries an absolute session-scratchpad
  path and reproduced identically; not touched, not reported as a regression.

**Canaries, spot-checked INDIVIDUALLY BY NAME** (`canaries.sh`, which prints and
counts ABSENT so a typo cannot read as green):

* surelog corpus: **52 canary rows, `ok=52 changed=0 absent=0`**. The two live,
  fragile conversions are intact — `InterfaceModPort` `CMP_EQUAL` both modes,
  `BlackParrotComplex` `CMP_EQUAL` both modes. `YosysBigSimReed` and
  `YosysOldOpen` `CMP_EQUAL` both modes; `YosysOldOr` `CMP_NOTEQUAL` both modes
  (unchanged). Pass-50's five collateral movers (`ClassParamAsParam`,
  `ClassTypeParam`, `SVSwitch`, `SimpleConstraint`, `ApbSlave`) all unchanged.
  `Scr1SvTests`, `BasicOh` `CMP_EQUAL`; `Earlgrey_0_1`
  `CMP_NOTEQUAL`/`SLANG_REJECT` as at baseline.
* uhdm2rtlil corpus: **8 canary rows, `ok=8 changed=0 absent=0`**.
* whole families diffed as blocks against the baseline: `Black*` **34 rows
  IDENTICAL**, `EvalFunc`+`ParamFile` **18 rows IDENTICAL**.
* the four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
  `TopParam`) were never dispatched.

## 10. GATE 5 — the byte verifier, BOTH corpora, every mover explained

Run BACKWARDS, as passes 50 and 51 did: the POST manifests come from the gate-3
and gate-4 sweeps, then the HEAD binary was run into the **SAME workdir paths**
and its manifests taken.

**The main-tree binary is NOT a usable control in this pass** — it was
`3cb9e2dc` (= my own control build) at the start and `3479e2d1` two hours later,
the other slot having rebuilt it. So the HEAD binary was rebuilt HERE from
`git checkout edfde51 -- include/UhdmExporter.h src/ExprEmit.cpp`, which
reproduced **`3cb9e2dc7ced2256cccb28a620fc774f` exactly**. My edits were copied
aside and copied back (**never `git stash`**), and `git diff edfde51` after the
restore is **byte-identical** to the diff taken before it (printed as
`RESTORE IS BYTE-IDENTICAL`). Both HEAD sweeps reproduced the committed
baselines exactly (`ROW DIFFS 0` against both), which independently validates
them as controls.

| corpus | paired | identical | DIFFER |
|---|---|---|---|
| uhdm2rtlil (`testflags`) | 679 | **679** | **0** |
| surelog (`both`) | 953 | 946 | **7** |

Path sets are IDENTICAL on both corpora (head 679 = post 679 = paired 679; head
953 = post 953 = paired 953). **Comparator negative control:** flipping one
character of one hash in the u2r POST manifest makes `bvcompare.sh` report
`identical 678 / DIFFER 1 / MOVER testflags/1DUnpackedArray-…`, so a real
difference cannot pass unnoticed.

**The 7 movers are EXACTLY the 7 target rows and NOTHING else:**

```
    [TARGET, and also KNOWN-NONDETERMINISTIC] default/Scoreboard
    MOVER default/BuildUVMPkg     MOVER testflags/BuildUVMPkg
    MOVER default/SeqDriver       MOVER testflags/SeqDriver
    MOVER default/SimpleUVM       MOVER testflags/SimpleUVM
```

**ZERO COLLATERAL MOVERS in either corpus**, out of 1632 emitted databases —
including every one of the 183 u2r `CMP_EQUAL`+dump-differ rows where the CSV
diff is BLIND. That matches pass 51's bar exactly.

`BuildUVMPkg` moved BYTES while its cmp head did NOT move: the law reaches the
class bodies throughout its 1800.2 `uvm_pkg`, but its first cmp-visible
difference is target 2 (§6), which sits in front of everything this law
touched. A byte mover with a stationary head is progress the row gate cannot
see — which is the whole reason gate 5 exists.

## Corrections I made to my own work, recorded

1. **THE CONTAINER-PRIORITY INSTRUMENT BUG (§1a).** My first predicate grid said
   golden binds ZERO class-method hier-path call arguments — a clean-looking
   confirmation of the brief that was an artefact of uhdm-dump printing the same
   body twice. It is now fixed in `bindiff.py` AND pinned by a selftest cell.
   Had I not caught it I would have shipped a gate that removed 2402 correct
   bindings.
2. **A CODE COMMENT THAT CLAIMED MORE THAN THE ARM MEASURED.** The first cut of
   the `recvCallArgDepth52` comment said "ob_* / pk_* (all nine) golden
   io_decl". False: `ob_stmt_bare_local` binds an `int_var` and
   `ob_stmt_bare_prop` binds a `logic_net` in the class view and nothing in the
   package view. The comment now names the two OUT-OF-BODY cells that actually
   carry the `!curSubOob9` half of the gate and states the property-argument
   exception. **The corrected-comment rebuild produced the SAME binary md5**, so
   no gate was invalidated.
3. **`bvcompare.sh`'s Scoreboard label**, flagged as misleading by the pass-50
   AND pass-51 integrations and never fixed, is fixed here.
4. **`heads.sh`'s header**, which claimed it walks "the UVM-4" while it walks the
   whole workdir (pass-51 integration item 5), is corrected, and it now warns
   that its normalised md5 is instrument-local.
5. **Numbers I did NOT re-measure and am not asserting:** the brief's R4 census
   of 479 declarations, and pass-51's 15 -> 180 -> 29 middle figure.


## Corrections applied at integration by the master (pass-52 verifier C1-C7 + my own)

**C1 — A CITED GUARD THAT WAS NOT THERE, now BUILT and both controls proven.**
This directory's `canaries.sh` header claimed *"a canary that appears in NEITHER
csv prints ABSENT and is counted, so a typo'd name can never read as green"*. The
code did `if [ -z "$b" ] && [ -z "$a" ]; then continue; fi` — a SILENT skip. I
reproduced the failure myself: injecting `ZZZ_TYPO_NOT_A_TEST` into `NAMES`
printed `ok=52 changed=0 absent=0` and exited 0. **A cited guard that does not
exist is worse than no guard, because every write-up leans on it** — and this
script is used by every pass.

The fix tracks matching PER NAME rather than per row, prints `UNKNOWN-NAME` for
any name matching nothing in either CSV in either mode, and counts it.

**AND MY FIRST FIX WAS TOO WIDE — MY OWN POSITIVE CONTROL CAUGHT IT.** Making an
unknown name FATAL broke the script permanently, because ONE `NAMES` list serves
BOTH corpora: the seven u2r-only canaries (`paramod_genscope_child`,
`issue326_packed_mem`, `assignment-pattern`, `hier_path`,
`MultirangesStartNotFromZero`, `genscope_cells`, `genvar_loop_decl_3`)
legitimately match nothing in a surelog CSV, so `exit 6` fired on a clean run.
The real defect was SILENCE, not tolerance. Unknown names are now always PRINTED
and COUNTED with the expected count documented, and the hard failure is opt-in via
`CANARY_STRICT=1`. Both controls verified: the real list gives
`ok=52 unknown-names=7` and rc 0; the injected typo appears BY NAME as an eighth.

**C2 — the code comment and README undercount the arms.** Both say "the three
`!callStmtCtx0` hier_path arms". There are **FOUR** such arms that emit arguments;
the patch guards three. See the MISS below.

**C3 — site 3's comment names a variable not in scope there** (`callStmtCtx0`
where the guard is under `stmtCtx`). Semantics correct, name wrong.

**C4 — README a2 table range error**: the row "`pk_*` (all seven) | 122-129" spans
**six** `pk_` cells; the seventh (`pk_nocall_index_formal`, line 130) is outside
the range AND is a non-call control, so "golden io_decl" cannot describe it.

**C5 — `heads.sh`'s `HEAD_MD5_IDNORM` column hashes the WHOLE cmp file**, not the
head, contradicting its own column name and header. It coincides only because
every measured file has exactly one head; it would diverge on a multi-head file,
and it does not strip the absolute `file:` path so it is path-sensitive too.

**C6 — `gold.sh` existence-checks surelog and slang but NOT `uhdm-cmp`/`uhdm-dump`.**

**C7 — `bvcompare.sh`'s unpaired-path tail is unlabelled and silently
`head -20`-truncated**; if path sets ever diverged the output would be bare
filenames with no header.

### THE MISS the verifier found (not a defect — it leaves a known-wrong bind standing)
`grep -n 'MakeHier_path' src/ExprEmit.cpp` inside the Call case returns **FIVE**
mints, **FOUR** under `!callStmtCtx0`, and this patch guards **THREE**. The
unguarded one is the DEEP-RECEIVER arm (`grep -n 'bool deepRecv11'`), which mints
a hier_path AND emits call arguments with no `RecvCallArg52`. The verifier built
the arm: in-body `if (mid.leaf.um52(f) == 0)` — **golden leaves `f` unbound, ours
binds an io_decl, PRE and POST byte-identical** — while the out-of-body twin binds
on both sides. Golden applies the SAME rule the law models, on a spelling the law
does not reach. Rank it beside R2: it is the same one-line insertion.

### The verifier's own new cell, and it is a GOOD one
The RAII covers the whole argument list and is never reset when `emitExpr`
descends into a nested call, so over-reach was plausible. Arm a4 settles it:
in-body `h.um52(bare52(f))` and `h.um52(f + g)` — **golden leaves all three refs
bare, our POST binary now does too, and the out-of-body twins where golden BINDS
are untouched.** The whole-arg-list reach is CORRECT, measured rather than assumed.

### Verified CORRECT, recorded so nobody re-checks
The `sed '1d'` / minus-2 arithmetic in `gold.sh` and `explainmover.sh`;
`csvdiff.py` counting rows from the parsed dict (731/1588, never `wc -l`);
`manifest.sh` / `bvcompare.sh` / `dumptree.py` / `bindiff.py` empty-input guards
(both selftests PASS); and the `LowMemPkg,testflags` baseline row with its absolute
session-scratchpad path reproducing byte-identically — do not touch it.
