# r10uvm15repro — UVM pass 15 purpose-built pairs

Run one with `tools/probe/r10uvm13run.sh <dir>` (needs `SLANG_UHDM` exported).
It writes `gd/ge` (golden def/elab) and `sd/se` (ours) plus `.txt` dumps into
the directory and prints both diff sizes.  Copy the directory somewhere
writable first — the runner drops artifacts next to `t.sv`.

`r10uvm13repro/t17` and `r10uvm14repro/{t18,t19}` are the earlier members of
this family and are re-used unchanged.

| dir | what it pins | status |
|---|---|---|
| t20 | class_typespec NAMING of a class-typed variable: package function vs package task vs class property vs inline method vs OUT-OF-BODY method vs formal vs module function, and a class from the SAME package vs an imported one vs a scoped name | § localClassTsUnnamed15 lands it — all 13 class_typespec name/loc pairs identical to golden |
| t21 | the same, with the classes and the methods split across `\`include` files (UVM's shape) | the include boundary changes NOTHING; lands with t20 |
| t22 | the over-fire check: is "class declared in the SAME design component" the discriminator, or only packages?  MODULE subroutines, `$unit` classes, imported classes, a nested `begin` inside a package function | § localClassTsUnnamed15 lands all six; def diff 72 -> 19 lines, remainder is an unrelated `vpiMethod` population gap |
| t23 | a local whose declared type is a parameterized class SPECIALIZATION (`Q #(Item) a;`) in every host | DISPROVES the "specialization -> no typespec" reading of UVM's `uvm_reg::add_hdl_path`: golden emits an ordinary unnamed class_typespec spanning the whole `Q #(Item)`.  Residue, unexplained |
| t24 | `typedef logic signed [W-1:0] bs_t;` used as a formal type — UVM's `uvm_object_globals.svh:49` | DISPROVES "the def view folds, the elab view does not": golden carries BOTH forms in BOTH views, so the `operation vs constant` cluster is a typespec-POINTER choice (which object the io_decl binds), not a folding-per-view rule.  Residue, ranked |
| t25 | a package typedef used as a scalar and as the element of a DYNAMIC / QUEUE / FIXED unpacked array, in every host | § arrayElemTypedefTs15 lands the dynamic and queue forms (they now bind the typedef's own object); the FIXED form `addr_t fix[4]` still mints a fresh element and the shared object's own name is `uvm_pkg::addr_t` where golden's is bare — both ranked |

## The laws

### § fileMacroAbs15 (`uhdm_main.cpp`)

`\`__FILE__` must expand to the file's ABSOLUTE path.  slang's
`SourceManager::cacheBuffer` stores each buffer's display name as
`fs::proximate(path)` — relative to the CWD — and `expandIntrinsic` builds the
`__FILE__` string literal out of exactly that name, so a UVM compiled from a
test directory produced `"../../UVM/uvm-1.2/src/base/uvm_object.svh"` where the
reference tool produces the absolute path.  `setDisableProximatePaths(true)` on
the driver's SourceManager, before any buffer is opened, is the whole fix.

This was measured, not guessed, and the measurement contradicted two passes of
hypothesis: the pass-14 ranking called `constant vs constant` a MACRO-ARGUMENT
ANCHORING problem, because a dump diff shows the golden constant at
`166:78`/`166:116`/`166:118` (each macro argument's own column) and ours at
`166:55`.  Locations are not cmp-compared.  Projecting the pairs onto the
properties `expr::Compare`/`constant::Compare` actually walk (`r10uvm15c
whycls`) says the failing property is **VpiDecompile** on 1626 of SeqDriver's
1626 constant pairs, and 1596 of those 1626 are this path string.  The
anchoring difference is real and invisible.

### § localClassTsUnnamed15 (`TypeEmit.cpp` ~415)

A class-typed variable declared INSIDE a subroutine or a statement block gets
an UNNAMED `class_typespec` when its class is declared in the SAME design
component, and keeps the name when the class comes from anywhere else.  The
committed rule had one case of this (a statement-block variable in a module);
the general form covers package subroutines, which is `uvm_globals::run_test`'s
`uvm_root top;` — 390 of SeqDriver's mismatching pairs.

Identity goes through the DEFINITION, not the instance body: a uniquified body
is a different `Scope` per instance while the class symbol keeps the scope it
was declared in.

The other direction in the census (209 pairs where GOLDEN names and we do not)
is a DIFFERENT law and is not this one — see the residue below.

### § arrayElemTypedefTs15 (`TypeEmit.cpp` ~352)

An unpacked array of a typedef types on its ELEMENT (the dims ride the wrapping
`array_typespec`), and that element is the TYPEDEF'S OWN typespec object, not a
fresh one at the declaration.  The scalar lookup misses it because the declared
type is the array.  `uvm_reg::get_address`'s `uvm_reg_addr_t addr[];` is the
UVM shape.  Honest accounting: this closes the OBJECT-IDENTITY half only — the
shared object's own `VpiName` is `uvm_pkg::uvm_reg_addr_t` where golden's is
bare `uvm_reg_addr_t`, so most of those pairs stay unequal and the measured
gain is 57 of 21942.  Kept because it is structurally right and gates clean;
the naming half is ranked below.

## Measured (UVM-4, default mode, body residue via `r10uvm7b`)

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | TOTAL |
|---|---|---|---|---|---|
| HEAD 94117ba | 4051 | 4521 | 10226 | 6928 | 25726 |
| § fileMacroAbs15 | 4051 | 4019 | 8759 | 5936 | 22765 |
| + § localClassTsUnnamed15 | 3971 | 3901 | 8370 | 5700 | 21942 |
| + § arrayElemTypedefTs15 | 3956 | 3891 | 8352 | 5686 | 21885 |

-14.9% overall.  BuildUVMPkg does not move on `fileMacroAbs15` because its
command line already names its sources absolutely.

## Tools

* `r10uvm15c.cpp` — `r10uvm7b` plus WHY.  `mode=why` prints, per differing
  pair, the properties uhdm-cmp actually compares (`VpiDecompile`, `VpiSize`,
  `VpiConstType`, the Typespec's actual kind+name); `mode=whycls` histograms
  the FIRST property that differs.  This is what turned "3451 constant pairs"
  into "1596 `__FILE__` strings".
* `r10uvm15v.cpp` — side-by-side listing of ONE task_func's Io_decls /
  Variables with each entry's typespec kind+name, golden vs ours.
* `r10uvm15m.sh` / `r10uvm15p.sh` / `r10uvm15rank.sh` — the pass-13 measuring
  trio re-pointed at this worktree and at `/tmp/r10uvm15_u4w`.

Build the probes with:

    g++ -O2 -std=c++20 -I$UHDM/build/generated -I$UHDM/include -o /tmp/r10uvm15_c \
        tools/probe/r10uvm15c.cpp -L$UHDM/build/lib \
        -L$UHDM/build/third_party/capnproto/c++/src/capnp \
        -L$UHDM/build/third_party/capnproto/c++/src/kj -luhdm -lcapnp -lkj -lpthread

## Ranked residue for pass 16 (SeqDriver `whycls`, after this pass)

| n | pair | first differing property | what it is |
|---|---|---|---|
| 496 | `Stmt` mfc vs mfc | deeper | the call-shape cluster; needs a drill into Arguments/Prefix/Function before any model |
| 331 | `Stmt` `<null>` vs mfc | presence | we emit a call golden does not |
| 317 | `Stmt` ref_var vs `<null>` | presence | |
| 285+285 | `Stmt` package/logic_net vs `<null>` | presence | a ref's Actual_group bound on one side only |
| 226+188+117 | bit_typespec vs bit_typespec | VpiName | **the typedef NAMING half**: same object, ours `uvm_pkg::uvm_reg_addr_t`, golden bare `uvm_reg_addr_t`, in the DEF view.  MEMORY warns this is context-dependent — decode it on a pair, do not sweep it |
| 246 | `Stmt` class_var vs int_var | VpiType | |
| 233+138 | `<null>` vs class_typespec | presence | golden's ref_typespec has NO actual (t23 shows the plain specialization is not the reason) |
| 229 | `Stmt` bit_typespec | VpiName | |
| 217 | mfc vs func_call | VpiType | |
| 141 | `Stmts` SIZE | | |
| 124+111 | class_typespec vs class_typespec | VpiName | the OTHER direction: golden binds a TYPEDEF'd specialization (`uvm_pkg::uvm_reg_cb_iter` at the typedef, 334:9), we mint a fresh unnamed one at the declaration.  Same family as the bit_typespec row |
| 148+147+141 | operation vs constant (both ways) | VpiType | t24 says this is a typespec-POINTER choice, not folding |
