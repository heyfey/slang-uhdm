# r10uvm42 — UVM pass 42

Pass 41 closed with a 3-row cmp-relevant residue whose first candidate
mechanism was already refuted, and an instruction: *find where the bare twin
with fan-in 135 is minted.* That framing was wrong, and finding out why turned
a 3-row residue into a **43-row one on SimpleUVM alone** and then closed it.

The bare twin is not a twin. It is a **per-declaration CLONE**, and golden mints
one for every declaration that reaches a vector typedef **through a container**.

## 1. § arrayElemTdClone42

> A VECTOR (`bit`/`logic`) typedef reached THROUGH A CONTAINER — an unpacked
> array's **ELEMENT** typespec, an associative array's **INDEX** typespec —
> takes a **PER-DECLARATION NAMED CLONE** of the typedef (bare name, the
> typedef's own span, `vpiInstance` = the listing object's, `Typedef_alias` ->
> the listing object **of this view**), never the listing object itself.
>
> An ENUM, STRUCT or CLASS typedef in the same position DOES take the listing
> object — golden spells those `<pkg>::<alias>` too. The restriction is the law.

Two call sites, one helper (`UhdmExporter::tdVecNamedClone42`, TypeEmit.cpp):

* `makeTypespec`'s § `arrayElemTypedefTs15` arm — the ELEMENT half. 40 of the
  43 rows.
* `assocIndexTs` — the INDEX half, i.e. **pass 41's ranked-first residue**. 3
  rows.

`isTdVecClone42` widens § `sharedAliasNoStamp41`'s no-stamp guard by one
predicate at all four `assocIndexTs` stamp sites: a clone is not
registry-shared, but golden does not re-span it either (every
`uvm_reg_addr_t` clone in SimpleUVM sits at the typedef's `73:10`, none at an
index bracket) and one clone IS shared between an `array_typespec`'s
`Elem_typespec` and the `array_var`'s element `reg`.

### Why pass 41's framing was wrong, and the probe that showed it

Pass 41 asked which of the two REGISTRY objects the index should take, measured
that both hold the same package-qualified object, and stopped. The measurement
was right; the question was under-specified. **A fan-in count cannot answer a
WHO question**, so this pass built `tools/probe/r10uvm42tw.cpp` — for every
named typespec: span, kind, name, `vpiInstance`, whether the object is a member
of some scope's typespec **LISTING**, its own `Typedef_alias` target, and the
multiset of its referring `ref_typespec`s' **PARENT kinds**. On golden's
SimpleUVM it says the whole law in two lines:

    73:10 bit_typespec 'uvm_pkg::uvm_reg_addr_t' inst=uvm_pkg LISTED alias=- fanin=154
                                            | 154 x bit_typespec'uvm_reg_addr_t'
    73:10 bit_typespec 'uvm_pkg::uvm_reg_addr_t' inst=uvm_pkg LISTED alias=- fanin=88
                                            |  88 x bit_typespec'uvm_reg_addr_t'

**All 242 references to golden's two listing objects come from a clone's
`Typedef_alias`, and not one from a declaration.** HEAD instead had 29
`array_typespec` refs and 3 `Index_typespec` refs straight to them. Golden's
clones are one per DECLARATION, and 27 of them read exactly
`1xarray_typespec | 1xbit_var` — the array's element typespec and the array's
element `reg`, sharing one clone, which is precisely what
`makeQueueDynArrayVar` already assumes.

The same census also refutes the framing directly: **the "bare twin with fan-in
135" was ours, not golden's.** An emitter trace (`R10UVM42TRACE`, since removed)
proved both registries return `uvm_pkg::uvm_reg_addr_t` at every one of the 174
share-path returns, so no code path was ever going to hand back a bare listing
object — there is no bare twin to find.

### What was already right, and what the law generalises

The io_decl arm (§ `unpackedTdElem9`, TaskFuncEmit) has built exactly this clone
for a **FORMAL** since pass 9. § `arrayElemTypedefTs15` chose the shared listing
object over an **UNNAMED** fresh one and never measured a **NAMED** one. So this
is the LOCAL / CLASS-PROPERTY half of a law that had only ever seen the formal
spelling — the same shape as pass 40's `queueLocalElemTsInstance40` and pass
41's two-registry guard.

### The unmeasured half, measured: arm `t59a`

The law was decoded on a PACKAGE-homed typedef. `t59a` carries a package
typedef (`pkc::w8`) and a **MODULE-scope** one (`mw8`) through every container
position (fixed / dynamic / queue / assoc-by-name, as class property, as body
local, as formal, plus plain scalars). Golden's answer for the module half is
the **same law**: the `mw8` listing object has fan-in 7 and all 7 refs come from
`bit_typespec 'mw8'` clones, one of them `1xarray_typespec | 1xbit_var`.

`t59a` also shows why the corpus barely moves outside UVM: a module-scope
typedef's listing object is already spelled **bare**, so taking it directly was
never a NAME difference — only an identity/span one. On `t59a` the law is
visible on both homes:

| direct container refs to a LISTING object | HEAD | this pass | golden |
|---|---|---|---|
| `pkc::w8` (2 listing objects) | 7 x array_typespec + 2 x constant | **0** | 0 |
| `mw8` | 3 x bit_var + 1 x bit_var 'lscalar' + 3 x logic_net (7) | **1** (`bit_var 'lscalar'`) | 0 |

## 2. Measurements (own binaries, idle box, PRE re-measured against a pristine-HEAD build)

**The cmp-relevant residue this law closes**, `r10uvm40av`'s projection on
SimpleUVM (`ts=`/`elem=`/`idx=` are all compared fields):

| | golden | HEAD | this pass |
|---|---|---|---|
| `bit_typespec 'uvm_reg_addr_t'` (bare) | 157 | 116 | **159** |
| `bit_typespec 'uvm_pkg::uvm_reg_addr_t'` | **0** | 43 | **0** |
| `idx=bit_typespec'…'@uvm_pkg` census row | 3 x bare | 3 x qualified | **3 x bare** |

and the whole-corpus version of the same thing, new metric **LISTDIRECT**
(`listdirect.sh` — container-position references that reach a LISTING object;
golden is NOT zero, because enum/struct/class indices legitimately do):

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | total |
|---|---|---|---|---|---|
| golden | 20 | 12 | 12 | 12 | 56 |
| HEAD | 50 | 48 | 78 | 48 | **224** (+168) |
| this pass | 22 | 18 | 22 | 18 | **80** (+24) |

**The pinned panel HELD to the unit**, PRE and POST measured on separate
workdirs with the two binaries:

| metric | HEAD `1eb4b9b` | this pass |
|---|---|---|
| `BINDWRONG` | 757 (43/87/521/106) | **757** (43/87/521/106) |
| `BINDTOTAL` | 1681 (938 extra / 743 miss) | **1681** (938 / 743) |
| `PAIRTOTAL` | 0 | **0** |
| `IOTOTAL2` / `IOTOTAL` | 3 / 2 | **3 / 2** |
| `INITTOTAL` | 52 | **52** |
| `CTORTOTAL` / `BODYOTHER` | 0 / 435 | **0 / 435** |
| `VARTOTAL` | 0 | **0** |
| `r10uvm23m` | 36 | **36** |
| `r10uvm28a` listing residue | 3663/3276/7941/3276 | **3663/3276/7941/3276**, element head byte-identical |
| **`r10uvm41ts` named-typespec residue** | 3862/3593/7986/3607 | **3827/3555/7974/3569** |

`r10uvm41ts` is one-directional on all four, which is what a law that both
renames and adds objects should do to a span-aware census.

**HONEST: `r10uvm42tw`'s own residue moves the WRONG WAY on SeqDriver** —
3894/3613/**8142**/3627 -> 3863/3581/**8148**/3595. It is not hidden and it is
not a model regression: the probe's WHO field makes it monotone in the
**sharing** residue, not in the name residue. We mint ONE clone per typedef per
VIEW where golden mints one per DECLARATION (SimpleUVM: 69 clones vs golden's
246), so every clone of ours carries several referrers and its line cannot match
any of golden's single-referrer lines. Adding 38 clones on SeqDriver therefore
adds 38 unmatched `>` lines while removing only ~32 `<` ones. The sharing
residue is **dump-only** (`uhdm-cmp` compares neither object counts nor
`Typedef_alias`) and is ranked below.

## 3. Gates — all four, on this worktree's own binary

`SLANG_UHDM` pinned to this worktree's `build/slang-uhdm` for every run
(`verify_golden.py:52` and `tests/check_goldens.sh:5` both default to the
MAIN-TREE binary and a false pass is indistinguishable from a real one).

* goldens **23 PASS / 0 FAIL**
* u2r `testflags`: **byte-identical** to `results/gate_uhdm2rtlil.csv` — 0 diff
  lines over 732 (679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`)
* Surelog both modes: **byte-identical** to `results/golden_surelog.csv` — 0
  diff lines over 1589, whole row **including DUMP**, so `SLANG_REJECT`
  membership is unchanged by construction and no pinned giant flaked
* **byte verifier** — every `slang.uhdm` the both-modes sweep emits, hashed HEAD
  vs patched with **both runs writing to the SAME workdir path**: **953
  databases, 946 identical, 7 differ, and the 7 are EXACTLY the 7 comparable
  UVM-4 rows** (BuildUVMPkg / Scoreboard / SeqDriver / SimpleUVM `default` +
  BuildUVMPkg / SeqDriver / SimpleUVM `testflags`). This is the sharp negative
  control the law needs, because it edits `makeTypespec` — the most general
  typespec builder in the emitter — and could have moved anything.
  * **`Scoreboard default` is excluded from the identity claim**: pass 41
    measured it NONDETERMINISTIC on every binary with `--jobs 1` (the recorded
    macro-buffer `SourceLocation` flake, PRE-EXISTING). The other six are real.
* the HEAD half of that run doubles as a **baseline-validity** check: its own
  CSV is byte-identical to the committed `results/golden_surelog.csv`, so the
  committed baseline is reproducible on this machine.

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL`. Nothing this pass emits
iterates a pointer-keyed container; the clone cache is keyed by
{declaration symbol, listing object} and is only ever read on the ordinary
emission walk.

## 4. Reproduce

    tools/probe/r10uvm42repro/probebuild.sh r10uvm42tw r10uvm28a
    tools/probe/r10uvm42repro/uvm4.sh ...        # (pass 41's driver: uvm4.sh)
    tools/probe/r10uvm42repro/panel.sh      <sweep-workdir>
    tools/probe/r10uvm42repro/res.sh        <sweep-workdir> <tag>
    tools/probe/r10uvm42repro/listdirect.sh <tag>
    tools/probe/r10uvm42repro/tsinst.sh     <sweep-workdir>
    tools/probe/r10uvm42repro/gold.sh t59a /tmp/r10uvm42_g59a
    tools/probe/r10uvm42repro/gate.sh goldens|u2r|sl|slbin ...
    tools/probe/r10uvm42repro/byteverify.sh <wd> <head-bin> <csv-head> <csv-post>
    tools/probe/r10uvm42repro/simpleuvm.sh <out-dir> [bin] [test]   # trace host

## 5. What is left, MEASURED — pass-43 ranking

**(1) THE `string_typespec` INSTANCE RESIDUE — 1074 rows, cmp-RELEVANT, and by
far the largest thing this pass measured.** `uhdm-cmp` RECURSES a typespec's
`vpiInstance`, so `@<class>` where golden says `@<package>` is a compared
difference. `tsinst.sh` (this pass, HELD identical PRE and POST so it is
pre-existing, not introduced):

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM |
|---|---|---|---|---|
| golden `string_typespec@uvm_pkg` / `@<class>` | 684 / **0** | 656 / **14** | 1392 / **12** | 656 / **0** |
| ours | 594 / **168** | 559 / **194** | 918 / **532** | 559 / **180** |

**DO NOT ASSUME THE RULE IS "NEVER THE CLASS"**: golden has 14 + 12 = 26 rows
that DO carry a class instance, so a blanket rewrite would break 26 rows while
fixing 1074 — find the discriminator first, exactly as pass 40's listing gate
had to be spelled per LISTING. Note also that `tsInst` at TaskFuncEmit ~2364 is
already `(pkgScope && !classScope) ? m : (oob ? oobHomePkg : nullptr)` and never
the class, so the class stamp comes from ANOTHER site — find it with a witness,
not by reading (pass 41's second site was found that way).

**(2) THE CLONE-SHARING RESIDUE, dump-only, and the reason `r10uvm42tw` moved
the wrong way on SeqDriver.** Golden mints one element/index clone per
DECLARATION (246 `uvm_reg_addr_t` clones in SimpleUVM); we mint one per typedef
per VIEW (69). `uhdm-cmp` compares neither object counts nor `Typedef_alias`, so
this is invisible to the verdict — but it is what keeps the span-aware censuses
from closing, and it is a one-line change to the cache key
(`arrayElemTdClone42`) whose blast radius must then be gated in full.

**(3) the `foreach` LOOP-VARIABLE index position, unmeasured.** `StmtEmit`
~1879 takes `sharedAliasTs(*ix19)` for a `foreach` loop variable over an
assoc-by-typedef-name array — the ONE remaining `sharedAliasTs` consumer this
pass did not route through the clone. Golden's invariant says a container
position never binds a listing object, so this is probably the same law again,
but it was **not measured** and was deliberately left alone rather than
generalised (pass 41's §4(2) warning).

**(4) the `uvm_severity` enum span, dump-only** — unchanged from pass 41: golden
spans its two `enum_typespec 'uvm_pkg::uvm_severity'` objects at `271:61` and
`352:37`, both `[uvm_severity]` INDEX brackets, not at the declaration `242:1`
where we put it. This pass CONFIRMS that residue is on the ENUM side of the
restriction: golden has no bare `uvm_severity` clone at all (`r10uvm42tw` shows
one `unsupported_typespec 'uvm_severity'` and two qualified enum objects), so
"always a clone" is NOT the enum rule and § `arrayElemTdClone42` correctly
excludes it.

**(5)-(8) carried, unchanged and untouched by this pass**: the
MODULE-IMPLICIT-NET arm (owns the whole of `BINDTOTAL`'s disclosed +4; binding
both views is a wash dressed as a win because `r10uvm28m` keys on a SET of
actuals); `BARE -> SELF` 438 rows, homogeneous PER ROUTINE; `BINDWRONG`'s 342
owner-attribution and 82 parameter-vs-folded-constant rows; the `IOTOTAL2`=3
POPULATION row; the MODULE arm of § `classKeyTsScopeOwner35`; the socket sharing
residue; `INITTOTAL`-52; t40a; `r10uvm23m` var=34; t36b; t33d.

## VERIFIER CORRECTIONS AND NEW FINDINGS (applied at integration, pass 42)

Two numeric mis-transcriptions above were CORRECTED in place; the direction of
every claim is unaffected:
 * the bare `bit_typespec 'uvm_reg_addr_t'` POST count is **159**, not 156
   (golden 157, HEAD 116 both reproduce with the same counting method, and
   SimpleUVM is byte-deterministic across sweeps, so this is not a flake). The
   3 extra rows are 2x `DEFPKG uvm_pkg::uvm_reg_map::get_base_addr | bit_var
   'get_base_addr'` duplicates — a PRE-EXISTING DEFPKG-vs-BOTH
   view-attribution difference — so we now sit 2 ABOVE golden on that row
   rather than 1 below. Nothing depends on it; the census total still improves
   1346 -> 1258.
 * the t59a `mw8` HEAD column is 7 refs, not 6.

THREE FINDINGS THE PASS DID NOT RECORD, all measured by the verifier:

(a) CACHE-KEY COLLISION BETWEEN THE TWO CALL SITES — and it makes ranked
    residue (2) NOT the advertised one-line change. `arrayElemTdClone42` is
    keyed {declKey, base}, and `makeTypespec` passes `(const void*)&declSymbol`
    while `assocIndexTs` passes `(const void*)&sym` — THE SAME POINTER for one
    declaration. So a declaration whose ELEMENT and INDEX are the same vector
    typedef shares ONE clone across two distinct container positions.
    Reproduced on a fresh arm (`v8 both[v8];` in a package plus a module-scope
    twin): golden mints TWO clones (`1xarray_typespec | 1xbit_var` and
    `1xarray_typespec | 1xconstant`) where we mint one with `fanin=4 |
    2xarray_typespec | 1xbit_var | 1xconstant`. NOT cmp-visible (the clone's
    compared fields are identical from either position) and the shape is ABSENT
    from the corpus, so it is not a defect in this patch — but THE KEY MUST
    GAIN THE POSITION (element vs index), not merely go finer on the
    declaration.

(b) THE bit/logic KIND GATE IS MEASURABLY INCOMPLETE FOR `int` TYPEDEFS. This
    README justifies the restriction with enum/struct/class only. Golden
    SimpleUVM's two `int_typespec 'uvm_pkg::uvm_action'` LISTING objects have
    fan-in 37 and 5, ALL of it from `int_typespec 'uvm_action'` clones and NONE
    from a container position — i.e. golden applies the same
    per-declaration-clone law to `typedef int uvm_action`. Ours still has
    `1xarray_typespec 'types_t'` binding that listing object directly
    (identical at HEAD, so PRE-EXISTING, and part of the remaining LISTDIRECT
    +24). MEASURE THE KIND GATE AGAINST int_typespec BEFORE CALLING IT THE LAW.
    Corroborating: golden's remaining 12 direct container refs on SimpleUVM are
    exclusively struct/enum typespecs, so the restriction IS right for those.

(c) ROBUSTNESS: `tdVecNamedClone42` hand-saves/restores `bypassTypedefShare`,
    `tfContext` and `tdCloneRefNoBind18` around a re-entrant `makeTypespec`
    call with NO RAII guard — any early return added inside that window later
    would leak emitter state. Wrap it if that arm grows.
