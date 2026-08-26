# r10v157 — ADVERSARIAL VERIFICATION of r10uvm157 § `stmtScopeTdListedOnEnclosingScope157`

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of the implementer's report
reproduced BIT-FOR-BIT from independently built binaries. Two
**pristine-right → patched-wrong** cells were found on legal SystemVerilog,
both in SITE 3's body-item count; both are FIXED here, minimally, and the fix
moves exactly ONE of the ten grid arms (the one that holds them) and NOTHING
else. Ship `/tmp/r10uvm157.verified.patch`.

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. The
official `uhdm-cmp` and `scripts/verify_golden.py` are. slang was NOT patched,
`results/*.csv` were READ ONLY, `GOLDEN_DEFER` stayed UNSET, no row was
promoted and no corpus row converted. The four slang-fenced tests were never
dispatched. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `1f9906a` |
| worktrees | `/tmp/wt_v157` (patched+fix), `/tmp/wt_v157pris` (pristine) |
| pristine binary | md5 `100987bc8d76f2052aa842d7c65c5110` — **identical to the implementer's** |
| implementer's patched binary | md5 `d27df00cf3c52be5bee8d3286ef2b9b2` — **identical to the implementer's** |
| VERIFIED binary (implementer + this fix) | md5 `cabffb3c7b71f3c90f1196f1502931b0` |
| all three frozen `chmod 555` before any sweep | |

---

## 1. REPRODUCTION — every headline number, from my own build

| the implementer claimed | I measured | |
|---|---|---|
| pristine md5 `100987bc…`, patched md5 `d27df00c…` | identical, from two fresh `1f9906a` worktrees configured and built here | ✅ |
| BuildUVMPkg def/tf **1371 → 163**, 1 head | 1371 / 1371 pristine, **163 / 163** patched | ✅ |
| the other ten head logs BYTE-IDENTICAL | SeqDriver ×2 (22), SimpleUVM ×2 (163), Scoreboard/def (163), MiniAmiq ×2 (106), Earlgrey ×2 (31/36), Rggen/def (0) — all `cmp -s` SAME | ✅ |
| corpus rows **0 changed** | `ct8rows` PASS: patched-vs-committed, pristine-vs-committed, patched-vs-my-own-pristine, all four CSVs | ✅ |
| CMP_NOTEQUAL stays 19 / u2r 679-50-2 | surelog default 10 + testflags 9 = 19; u2r default & testflags 679/50/2 | ✅ |
| byte movers **2/956** surelog, both BuildUVMPkg, **0/1358** u2r | `SELFCHECK=1 byteverify` — `MOVERS: 2 / 956` (`./default/BuildUVMPkg-bf853d43`, `./testflags/BuildUVMPkg-bf853d43`), `MOVERS: 0 / 1358`; the Scoreboard coin did not flip on my run either | ✅ |
| binary-path audit 1523 + 1458 references | 1523 `/tmp/v157_bin/pat.bin` in the surelog sweep's 1573 `cmds.txt`, 1458 in the u2r sweep, **zero** main-tree references, zero cross-binary references | ✅ |
| grid 210 → 34 differing cells | on the implementer's own five arms: a_scope 35→0, b_form 76→28, c_count 36→0, d_sub 23→6, e_edge 40→0 = **210 → 34** | ✅ |
| R0 = `begin @ uvm_pkg.sv:61835:28`, `Variables` LHS=1 RHS=null | the new head log is exactly that `begin`, `vpiVariables \_ref_var (…::t) @61836:15`, `RHS: <null>` at line 163 | ✅ |
| patch applies clean on a fresh `1f9906a` | `git apply -3` in a fresh worktree: 5 files "cleanly", 0 conflict markers | ✅ |
| surface = production + `tools/probe/r10uvm157repro/` only | 5 production files (+371/−0) + 49 probe files; **no** `results/*.csv`, no slang, fence check 0/0/0/0 | ✅ |
| goldens 23/0 + `/bin/false` 23 FAIL | 23/0 patched, 23/0 pristine, 0/23 with `/bin/false` | ✅ |

---

## 2. THE TWO DEFECTS FOUND — SITE 3's BODY-ITEM COUNT WAS AN **AST** COUNT

`subroutineBodyItemCount157` decided SITE 3 by walking slang's AST: four member
kinds plus the body statement list, with an `Empty` body deliberately not
counted. Surelog decides it by walking its PARSE TREE
(`MoreStatement_or_null = fC->Sibling(Statement_or_null)`,
`CompileStmt.cpp:2037-2041`), so what it counts is the WRITTEN ITEM LIST. Two
written items are invisible to the AST count:

| arm cell | source | golden | implementer's patch | pristine |
|---|---|---|---|---|
| `bakeNull157` | `task t; typedef bit[3:0] q; ; endtask` — a NULL STATEMENT | task `Typespecs` **null**; the entry is on the synthesised `begin` spanning the `;` | task `N=1` — **AWAY** | task **null — RIGHT** |
| `bakeLet157` | `task t; typedef bit[3:0] q; let w(x)=x+1; endtask` — a LET DECLARATION | task `Typespecs` **null**; the entry is on the synthesised `begin` | task `N=1` — **AWAY** | task **null — RIGHT** |

Both are legal SystemVerilog and both are **judge-visible**, measured with the
official `uhdm-cmp` on two-file repros that contain nothing else
(`/tmp/v157_min/p1_null.sv`, `p2_let.sv`):

```
p1_null   PRISTINE 59 cmp lines, head = begin(Ledger157::tallyNull157)@4:5   <- golden's body begin, a §145 residue
          PATCHED  69 cmp lines, head = LHS:<null> / RHS: task(...) |vpiTypedef: bit_typespec(markNull157)
```

The head MOVED EARLIER in `scope::Compare`'s walk — from the `Stmt` residue the
pass does not claim, to the `Typespecs` vector (`scope.cpp:348`) the pass had
just populated. That is the definition of a regression: a field pristine passed
and the patch fails.

`let` is `UH0701 Unsupported statement` to Surelog and slang models it as
neither a counted member kind nor a body statement — yet **Surelog still counts
it as a sibling** and synthesises the wrapper. That is the point: the count must
not be an inventory of what either tool MODELS, only of what the SOURCE WRITES.

### The fix (this verifier's, `src/EmitHelpers.h`)

`subroutineBodyItemCount157` now returns
`sub.getSyntax()->as_if<FunctionDeclarationSyntax>()->items.size()` — slang's
own written-item list, one entry per `block_item_declaration` and per
`statement_or_null`, for `function` and `task` alike (slang uses one syntax node
for both, the established idiom at `src/TaskFuncEmit.cpp:5103`). The AST count
survives only as the fallback for a subroutine with no such syntax (a builtin
method), which can hold no written typedef.

It reproduces **all eight** golden answers the implementer measured for the
threshold, plus the two this verifier measured, plus `typedef q; begin end`
(golden: on the `begin`; items = 2 → correctly does not fire):

| body | items | where golden lists | ours |
|---|---|---|---|
| `typedef q;` | 1 | the TASK | the TASK ✅ |
| `typedef q1; typedef q2;` | 2 | the synthesised `begin` | nowhere (a declared residue) |
| `parameter K=2; typedef q;` | 2 | the synthesised `begin` | nowhere (residue) |
| `typedef q; q v;` | 2 | the synthesised `begin` | nowhere (residue) |
| `typedef q; return 1;` | 2 | the synthesised `begin` | nowhere (residue) |
| `typedef q; ;` | 2 | the synthesised `begin` | **nowhere ✅ (was the TASK)** |
| `typedef q; let w(x)=x+1;` | 2 | the synthesised `begin` | **nowhere ✅ (was the TASK)** |
| `typedef q; begin end` | 2 | the synthesised `begin` | nowhere (residue) |

After the fix `p1_null` and `p2_let` are **byte-identical to the pristine
database** and their cmp heads are the pristine ones again.

### The fix's blast radius, measured

Rebuilt the whole probe grid with the implementer's binary as A and the fixed
binary as B: **of the ten grid arms (five the implementer wrote, five this
verifier wrote), exactly ONE moved — `v157_e_count`, the arm holding the two
cells.** The other nine are byte-identical in both views. On the implementer's
own five arms the fixed binary scores exactly what they reported:
a_scope 35→0, b_form 76→28, c_count 36→0, d_sub 23→6, e_edge 40→0.

---

## 3. THE ADVERSARIAL GRID — five arms this verifier wrote

Different vocabulary, different case conventions, different widths, different
containers from the implementer's; no arm names anything `a_t/b_t/c_t`.

| arm | what it attacks | pristine → verified (differing cells, `--listed`) |
|---|---|---|
| `v157_a_home.sv` | **SITE 3's HOME axis** — a subroutine whose whole body is one typedef, in a package, a class (in-body, `static`, `virtual`, **out-of-body**), an **interface**, a **program**, a module (bare and with an ANSI port), and a `$unit` free task. The implementer measured only a package task and a module task. | 14 DIFF + 1 ONLY-G → 2 DIFF + 1 ONLY-G + 2 ONLY-O |
| `v157_b_shape.sv` | **TARGET FORMS the implementer did not write** — multi-dimensional packed `bit [3:0][7:0]`, the `reg` spelling, a `$clog2()` bound, a localparam bound, `bit signed`, `byte unsigned`, `event`, `chandle`, `real`/`realtime`/`time`, a typedef **SHADOWING a module typedef of the same name**, a FORWARD typedef followed by its own definition, and a `virtual` interface typedef | 22 DIFF → 4 DIFF |
| `v157_c_face.sv` | **SCOPE FACES + MULTIPLICITY** — a parameterised class with two specialisations, a `fork` arm nested in a task body beside an unnamed sibling arm, `always_ff`, an inner `begin` shadowing an outer typedef NAME, `do..while`, a `case` `default` arm, a **generate loop with two iterations**, and the whole module **instantiated twice** | 24 DIFF → **0** |
| `v157_d_carve.sv` | **THE TWO CARVE-OUTS, PUSHED** — a ctor with a sole typedef, a ctor with `super.new()` **and a written `begin`**, a NON-ctor sibling method right beside it, the TF-ITEM production, its ANSI twin, **a TF-ITEM body with a nested written `begin`**, ports of all four directions, a `$unit` task, and a class declared inside a module | 7 DIFF + 2 ONLY-G → 0 DIFF + 2 ONLY-G + 1 ONLY-O |
| `v157_e_count.sv` | **SURELOG'S ITEM COUNT, ATTACKED** — twelve bodies, each one item that slang models without a counted member and without a statement | 8 DIFF + 12 ONLY-G → **4 DIFF** + 12 ONLY-G (**the 2 AWAY cells × 2 views cleared**) |

**`c_face` at 0 differing cells is the strongest single result**: two module
instances × two generate iterations × two class specialisations all carry their
own elaborated copy of the listing, in both views, byte-exact against golden —
and the shadowing pair (`c_outer157` / `c_inner157`, one name, two widths, one
nested in the other) resolves to two distinct objects, not one shared one.

**`d_carve` proves the two carve-outs are gates and not blankets**: the ctor with
a written `begin` lists nothing, and the non-ctor method in the SAME class,
written immediately after it, still lists — the ctor gate does not leak to its
siblings. The TF-ITEM task lists nothing while its ANSI twin lists, and a
TF-ITEM task with a NESTED written `begin` DOES list there (golden too): the
carve-out is on the subroutine's own typedefs, not on its nested blocks.

**No cell anywhere moved AWAY except the two named in §2** (and the two §4.1
residues, which are on objects that have no golden counterpart at all).

---

## 4. RESIDUES, RANKED — measured, each with its repro

### 4.1 A FILE-CONTENT (`$unit`) SUBROUTINE OVER-FIRES — declined, judge-invisible

Golden compiles a subroutine whose DEFINITION is a compilation-unit item under
`FileContent`, i.e. with `reduce == Reduce::Yes`, and hangs its typedef on the
**DESIGN's** `vpiTypedef` with `vpiInstance = design`. We hang it on the
subroutine. Two shapes measured:

* `task automatic driftUnit157; typedef bit [3:0] siltGrain157; endtask` at
  `$unit` — golden emits **no task object at all** and puts the typespec on the
  design (`v157_d_carve`, and the standalone `/tmp/v157_min/p5_unit.sv`).
* `task Anvil157::hammer157; typedef bit [9:0] scale157; endtask` written at
  `$unit` for a `$unit` class — golden's single `hammer157` is the EXTERN
  declaration (`vpiAccessType:2`, no body, `Typespecs` null) and the typespec is
  on the design (`v157_a_home`).

**Judge impact: NONE, measured both ways.** In the `$unit`-task shape the head
is byte-identical pristine and verified (28 cmp lines, a pre-existing
`func_call` mismatch far earlier); in the out-of-body shape the head ADVANCED
(from the `chisel157` task this pass fixes to the `class_defn work@Anvil157`
`Task_funcs` **size** mismatch — we emit two `hammer157` objects where golden
emits one, which pristine does too). In both, the object we decorate has no
golden counterpart, so the walk cannot reach the new field.
**Bytes do move** (23 added dump lines on `p5_unit`, all the listing entry).
NOT gated here: a "$unit home" predicate is new and unmeasured, the corpus reach
is zero (the a-priori census found the law's only corpus scope is BuildUVMPkg's
one `begin`), and the containing objects already diverge structurally. **This is
the first thing a follow-up pass on out-of-body/`$unit` subroutines must fix.**

### 4.2 `typedef virtual <iface>` IS LISTED IN GOLDEN — the law's text is REFUTED

The law states a `virtual` interface typedef takes Surelog's DummyType arm and
is "pushed NOWHERE". **Measured, golden, both views** (`v157_b_shape`, scope
`b_nameonly157`, which holds a bare-identifier typedef, a class-name typedef and
a `virtual` typedef side by side): golden lists **N=1** — the `virtual` one, as
an `interface_typespec` named for the typedef — and pushes the other two
nowhere. The implementer's `b_form` contains **no `virtual` typedef at all**, so
that clause was inferred from Surelog source and never measured.
Behaviourally harmless (Skip and Decline produce the same object graph, and the
answer is an ONLY-GOLDEN under-fire, never an AWAY), so the code is unchanged
except for an amendment comment at `stmtScopeTdListForm157` recording the
measurement so the refuted reading is not re-stated.

### 4.3 `typedef realtime` GETS THE WRONG TYPESPEC KIND — PRE-EXISTING, another law's

Golden gives `typedef realtime X` a **`time_typespec`**; we give it a
`real_typespec`. `/tmp/v157_min/p4_rt.sv` shows the same disagreement on a
**MODULE-level** typedef in the PRISTINE binary, so it is the shared
`makeTypespec`'s answer and belongs to § `atomTdListing44`, not to this pass —
this pass merely reproduces it in a new place (`v157_b_shape` `b_realtime157`,
where entry `I1` is the only wrong one of three and the vector SIZE is right).

### 4.4 A `static` CLASS TASK's OWN SPAN — pre-existing, not read by the judge

`static task temper157;` — golden spans the task `19:3-19:57`, we span
`19:3-19:9`. Identical in the pristine binary, identical listing payload, and no
generated `Compare` reads a line or a column. It is why `v157_a_home` shows
`ONLY-G` + `ONLY-O` for that one cell under a span-keyed census.

### 4.5 CONFIRMED, the implementer's own declared residues

Re-measured and unchanged by the fix: the enum/struct/union/unpacked-array
whole-scope decline (`bakeEnum157`, `b_form` b18-b30); the subroutine wrapper
threshold that leaves `typedef q; <one statement>` unlisted
(`d_carve` `barge157`, `e_count` `bakeEmpty157` / `bakeTwo157` /
`bakeParam157` / `bakeLocal157` / `bakeFwd157` — all ONLY-GOLDEN, never AWAY);
the module-homed SITE-3 task listing **twice** in golden (`d_sub`
`soleTdModTask157` `N=2` vs our `N=1`; my `a_home` `simmer157` reproduces it
independently); and the `g22` / `l154_noenum` folded constant that moves exactly
one 4096-byte page for any binary image.

**A shape golden and we AGREE on that is worth recording:** a `function` whose
only body item is a typedef (`function int f; typedef bit[3:0] q; endfunction`)
lists **nowhere** in golden — unlike the `task` spelling, which lists on the
task_func — and we list nowhere too, before and after the fix
(`/tmp/v157_min/p3_fn.sv` is **CMP_EQUAL, 0 lines**, on the patched and on the
fixed binary, against 69 lines pristine). The `void` spelling of that same shape
segfaults Surelog and is in no arm, exactly as the implementer recorded.

---

## 5. HOW TO REPRODUCE

```bash
# the five adversarial arms, both views, two binaries
bash grid157_v.sh arms/v157_a_home.sv <binA> <binB> <workdir> <ct157cen>
python3 score157_v.py <workdir>/cen.g.txt <workdir>/cen.b.txt --listed

# the two regression repros (two files, nothing else in them)
#   p1_null.sv:  package P; task automatic t; typedef bit [3:0] q; ; endtask endpackage
#   p2_let.sv:   package P; task automatic t; typedef bit [3:0] q; let w(x)=x+1; endtask endpackage
# uhdm-cmp <golden> <ours>  -- 59 lines pristine, 69 with the unfixed patch, 59 fixed

# the wide boundary, over a COPY of the whole probe tree
PRIS=<pristine> PATCHED=<fixed> bash bound157_v.sh <copy-of-tools/probe> <outdir>

# the census tool is r10uvm157repro/ct157cen.cpp verbatim (copied as ct157cen_v.cpp)
g++ -O2 -std=c++17 ct157cen_v.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
    -luhdm -lcapnp -lkj -o ct157cen
```
