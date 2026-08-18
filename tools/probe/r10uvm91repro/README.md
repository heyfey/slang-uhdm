# r10uvm91 — § `classTpTdGroupNonClsRootShared91` — **the `this_rsp_type` head closed on all seven UVM row-modes**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
PASSES cmp**.

## The headline

r10uvm90 left ONE head on all seven live UVM row-modes — an `int_typespec`
**VpiName**. It is gone, and so is the whole family behind it.

| row-mode | cmp lines | head |
|---|---|---|
| SeqDriver ×2 / SimpleUVM ×2 / MiniAmiq ×2 / Scoreboard-default | 24 → **176** | `int_typespec` `this_rsp_type` vs `this_req_type` → `hier_path(gp.m_byte_enable[i % ])` **VpiName** |
| BuildUVMPkg ×2 | 140 → 140 | unchanged (`io_decl` family) — but **27 objects moved per mode** |
| Earlgrey_0_1 ×2 (9743/33), Rggen-default (122) | unchanged | untouched, and **provably byte-untouched** (0 of 956 − 9) |

**24 → 176 cmp lines is NOT a regression.** Heads stayed at **1** on every
row-mode, and the ladder proves the new one from the **pristine database alone**:
pristine `RUNG 7` is patched `RUNG 1`, verbatim. A cmp line count is the head
object's decompile size, and a `hier_path` over a nested `bit_select` decompiles
to 88 lines a side where an `int_typespec` decompiles to 6.
`LADDERS.r10uvm91.txt`: the pristine ladder runs to **FIXPOINT: 397 rungs**, the
patched one to **FIXPOINT: 391** — down by **exactly the six rungs** this law
removes, and the family string is **absent from the patched ladder entirely**.

## The head, and what it actually was

```
LHS golden  int_typespec (this_rsp_type)  @uvm_imps.svh:232:70-232:73
              < class_defn(uvm_pkg::uvm_blocking_master_imp)
RHS ours    int_typespec (this_req_type)  @236:11-236:18   (no parent)
```

`uvm-1.2 src/tlm1/uvm_imps.svh:232`, the same shape six times (232/243/254/265/
276/287):

```systemverilog
class uvm_blocking_master_imp #(type REQ=int, type RSP=REQ, type IMP=int,
                                type REQ_IMP=IMP, type RSP_IMP=IMP)
  extends uvm_port_base #(uvm_tlm_if_base #(REQ, RSP));
  typedef IMP     this_imp_type;
  typedef REQ_IMP this_req_type;
  typedef RSP_IMP this_rsp_type;
  `UVM_MS_IMP_COMMON(...)     // local this_req_type m_req_imp;
                              // local this_rsp_type m_rsp_imp;
```

`scope::Compare` reads **Variables** before **Parameters** before **Typespecs**,
so the head is the class PROPERTY `m_req_imp` — and the object it points at is
the one this pass moves. **232:70-232:73 is the `int` of `type IMP=int`**: golden
is not naming a typedef's own object, it is naming and SHARING **the class
HEADER default's** object.

## The law

> A class holds **ONE** typespec per **DEFAULT-CHAIN ROOT** among its own type
> parameters. The object is the one built from the **ROOT parameter's
> CLASS-HEADER DEFAULT**; it is **NAMED** after the typedef of the **LAST
> parameter of that chain** (in declaration order) that has a candidate typedef;
> and every member of the chain binds it — each `type_parameter`'s own typespec,
> and the **FIRST** candidate typedef of each member, which is therefore also the
> class's `vpiTypedef` LISTING entry and what every property written as that
> typedef reads.
>
> A typedef written with **DIMENSIONS** is an `array_typespec` **over** the
> parameter, not a typedef **of** it, and is not a candidate.

`§ classTpTsResolvedNameEverySite87` owns the **CLASS-resolved** half of this
shape and recorded the rest as its residue **R1**. This is R1, for the
NON-class, NON-aggregate kinds.

### The two cells that fix the two halves of the sentence

Both read off **ONE** golden in `g91_a1_grid.sv`, and neither can be read off UVM:

* **`c_root #(type A=int, type B=A)` with a typedef on `B` ONLY.** Golden's one
  object sits at **`A`'s `int`** — the chain ROOT, 21 columns away from `B`'s
  `A`, and `A` has no typedef at all. The anchor is the ROOT, not the first
  group member. (`c_uvm`'s root `IMP` is also its first member, so the corpus
  cannot separate them.)
* **`c_two #(type A=int, type B=int)`, a typedef on each.** Golden emits **TWO**
  objects, `a_t` and `b_t`. Two parameters of the **same resolved type** but of
  **different chains** are **different groups** — the one cell that separates
  this key from § `classTypeParamTdGroupLastWins33c`'s "resolved type" key.
  `t45a` gives every same-typed parameter the same chain and could not tell them
  apart; § 33c's own note asked for exactly this cell.

The winner table itself is § 33c's, with the r10uvm87 VERIFIER's three
eligibility rules (a typedef-of-a-typedef **CONSUMES** its target; among ONE
parameter's typedefs the **FIRST** wins; a `local`/`protected` typedef is not a
candidate) — and `c_ord #(A=int, B=A, C=A)` with typedefs written `c_t, a_t,
b_t` re-reads § 33c's headline cell at a site § 33c never reached: golden names
the LISTING `c_t` (the LAST PARAMETER's typedef) where our pristine build named
it `b_t` (the last typedef declared). **The two coincide in UVM**, which is why
the corpus never showed it; the arm does.

### What golden does that this pass does NOT claim

Read off the same golden, measured, recorded, not implemented:

* **R1** — the **enum / packed-struct / union** groups. Golden reaches them by
  **RENAMING THE PACKAGE'S OWN SHARED LISTING OBJECT** (`c_enum`/`c_st`: golden
  reads `enum_typespec 'p91::b_t'` *at the package typedef's own span*). That is
  § `tdListingFormalAsWritten33`'s whole-corpus graph, excluded by predicate for
  the same reason § 33c and § 87 exclude it.
* **R2** — a property / body local / return written as the **PARAMETER NAME**
  (`A p_a;`). Golden binds the group object; we still mint an anonymous one.
  30 arm cells, **ZERO corpus reach** — the depth-keyed corpus census finds no
  such cell, which is why the site is measured and left alone rather than
  implemented on a shape only the arm exercises.
* **R3** — a **SECOND** typedef of the same parameter (`c_dbl`): golden keeps
  three LISTING entries (the shared object under the winner's name, plus the two
  extra typedefs' own objects) and `emitClassTypedefs`' § 25 grouping collapses
  them to one. Pre-existing, unchanged. Golden's LISTING order there is
  `b1_t, a2_t, b2_t` — **not** name-sorted, which our `emitClassTypedefs` is;
  no corpus class has two typedefs of one parameter, so it is recorded, not
  chased.
* **R4** — golden's SPAN moves to the **LAST FORMAL written as a parameter name**
  when there is one (`c_notd` 97:23, `c_sites` 149:28), and falls back to the
  header default otherwise. Every corpus site is written as a TYPEDEF name, so
  the corpus takes the header-default branch and our object's span is golden's.
  Span is dump-only; `Compare` never reads it.
* **R5** — a `local`/`protected`-only group (`c_qual`) reaches golden's class as
  **no vpiTypedef LISTING entry at all**; we still list one. Pre-existing;
  the group object is ANONYMOUS on both sides, so no cmp field moves.

## Where the code is

| site | file | what changed |
|---|---|---|
| table | `src/TypeEmit.cpp` `classTpGroupNc91` | § 33c's winner table + § 87's three eligibility rules, keyed on the **default-chain root** (`tpAliasRootOf25`) and narrowed to an ALLOW-list of the scalar kinds; cached per class body |
| object | `src/TypeEmit.cpp` `classTpGroupNcTs91` / `classTpGroupNcTdTs91` | the ONE object, minted on first ask from the ROOT parameter's own header default — the **same `makeTypespec(param, defaultSyntax)` call `emitClassParameters` already made**, so its KIND and SPAN are what our pristine build already produced and only the NAME and the SHARING are new |
| **A** | `src/UhdmExporter.cpp` `emitClassParameters` | the non-class `type_parameter` arm binds the group object — **18 of the 24 corpus cells** |
| **B** | `src/UhdmExporter.cpp` `buildClassTypedefTs` | a group member's FIRST candidate typedef BINDS the object instead of minting one — **the remaining 6, and the head** |

Nothing else is touched. `emitClassTypedefs`' § 25 grouping, § 33c's
`emitTaskFuncs` code and § 87's `classTpGroup87` are all **unmodified**: once
site B makes the three typedefs one object, § 25 lists it and § 33c's SHARE arm
finds it already correct.

## The regression the census caught, before any gate ran

The first cut had no `dimensions.empty()` test on the candidate walk. The
depth-keyed census (golden vs pristine vs patched, joined on the
`(class, SITE)` key) read back **six pristine-right → patched-wrong cells by
name** in one run — `uvm_spell_chkr #(type T=int)`'s `typedef T tab_t[string];`
and `uvm_utils #(type TYPE=int)`'s `typedef TYPE types_t[$];`, whose
`array_typespec`s we turned into `int_typespec`s and whose type_parameters
golden leaves **anonymous**. **The corpus was its own counter-example**, and arm
cells `c_dim` / `c_dim2` were written afterwards to hold the lesson.
`CENSUS.r10uvm91.txt` §C.

## The numbers

* **corpus census**: NAME disagreements on `default/SeqDriver`
  **215 → 191**, `−24` and only `−24`; remaining `int_typespec` NAME
  disagreements **0**; pristine-right → patched-wrong **0**.
* **byte verifier**: **9 movers / 956** on surelog (the 9 UVM databases, every
  one predicted from pristine bytes first), **0 / 1358** on uhdm2rtlil. Each
  mover moves **exactly 216 dump lines** and every moved line is
  `int_typespec` / `type_parameter` / `|vpiSigned` / `|vpiParent` /
  `|vpiName:this_r??_type` — **nothing else**.
* **row gates**: **0 differing rows** over 1588 (surelog) and 1462 (uhdm2rtlil),
  against the committed baselines AND patched-vs-pristine, status **and** dump
  column. No row converted in either direction.
* **boundary**: 616 arm sources, **7 moved**, and **every one moves TOWARD
  golden** (`t45a` −144 dump lines, the rest −4 to −6); 7 `NO_OUTPUT` fail on
  **both** binaries. Every CLASS-resolved cell of uvm87's arms is byte-identical.
* **arm** (27 classes, `g91_a1_grid.sv`): NAME disagreements **80 → 41**, SPAN
  **36 → 23**, KIND unchanged at 4, **0** pristine-right → patched-wrong. The
  41 that remain are 34 R2 cells, 6 R1 cells and 1 pre-existing `array_typespec`
  listing cell — `CENSUS.r10uvm91.txt` §E names all three groups.

## Reproducing

```sh
# arms (golden + both binaries in ONE scratch dir)
PRI=<pristine> PAT=<patched> ./arm91.sh g91_a1_grid.sv
# census + the regression check that caught the dimensions bug
g++ -O2 -std=c++17 ct91cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct91cen
./ct91cen <db.uhdm>            # one row per (class_defn, SITE), object ordinals
./ct91cen <db.uhdm> --pred     # the mover predictor, PRISTINE bytes only
./cen91.py g.cen pris.cen pat.cen --kind=int_typespec
# gates
./sweep91.sh <binary> surelog pat ; ./ct8rows.sh <baseline.csv> <fresh.csv>
./pred91.sh <pristine workdir> PREDICT.txt
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh <pat wd> <pris wd>
./pins91.sh <pat wd> <pris wd> ; ./canaudit.sh canaries.sh ctcan2.sh
PRI=<pristine> PAT=<patched> ./bound91.sh
# the ladder (measurement only)
/tmp/r10uvm91_ctladder <golden.uhdm> <ours.uhdm> --budget=2400
```

## One driver fix, made here

`v87bound.sh` keyed each source's scratch dir on the **basename**, and
`r10uvm33repro` keeps **three** arms all named `dut.sv` (`t43a/`, `t44a/`,
`t45a/`). Two of the three were silently overwritten and could never have been
reported as movers. `bound91.sh` keys on the **relative path**; re-run after the
fix, the mover set is the same 7 and `t43a` / `t44a` are confirmed **unmoved**.

## RANKED for pass 92

1. **The new head — `hier_path` VpiName / `ref_obj` VpiFullName**, on all seven
   UVM row-modes (`uvm_tlm2_generic_payload.svh:464`). Golden decompiles the
   index of `gp.m_byte_enable[i % gp.m_byte_enable_length]` as
   `gp.m_byte_enable[i % ]` — it **truncates the second operand of the modulo**
   — and prefixes the inner `ref_obj` fullnames with the whole hier_path text
   (`…::gp.m_byte_enable[i % ]::m_byte_enable::i`) where we write
   `…do_compare::i`. Two fields, one object, and the ladder shows the rung is
   the same on both sides.
2. **R2 — the parameter-name-spelled property / local / return** (30 arm cells,
   0 corpus reach today). Cheap now that the group table exists: one call to
   `classTpGroupNcTs91` from `makeTypespec`'s scalar arms. Worth doing when a
   corpus row needs it, not before.
3. **R1 — the enum / struct groups.** Real, measured, and gated behind the
   package-listing graph; it wants the same pass as § 33c's `t41b` residue.
4. **BuildUVMPkg's own head** (140 cmp lines, unmoved by this pass).
