# r10uvm41 — UVM pass 41

Pass 40 ranked its own defect first, and that is what this pass is: **a bug
fix, not a law**. Pass 40's new `makeAssocArrayVar` stamped `setLoc`,
`Instance` and `VpiSigned` onto the typespec object handed back by
`assocIndexTs`, which for a TYPEDEF-NAME index is the ONE object every user of
that typedef points at. The in-code comment claimed only the freshly-minted
predefined-integer arm was touched, but **the guard tested the CANONICAL KIND**,
so `typedef int myint` — a `PredefinedIntegerType` canonically — walked
straight through it.

Fixing it exposed that the hazard was not one site but **three**, and that the
INHERITED site (`UhdmExporter::emitAssocDims`, the class-property path) is the
one with REAL CORPUS REACH: it was re-spanning four shared UVM typespec objects
with a combined fan-in of **271 references** in SimpleUVM alone.

| metric | HEAD `36b3234` | this pass |
|---|---|---|
| `r10uvm38w.sh` `BINDWRONG` | 757 (43/87/521/106) | **757** (43/87/521/106) — held |
| `r10uvm28m.sh` `BINDTOTAL` | 1681 (938 extra / 743 miss) | **1681** (938 / 743) — held |
| `r10uvm31m.sh` `PAIRTOTAL` | 0 | **0** (held) |
| `r10uvm30iom.sh` `IOTOTAL2` | 3 | **3** (held) |
| `r10uvm29iom.sh` `IOTOTAL` | 2 | **2** (held) |
| `r10uvm29m.sh` `INITTOTAL` | 52 | **52** (held) |
| `r10uvm27m.sh` CTOR / BODYOTHER | 0 / 435 | **0 / 435** (held) |
| `r10uvm26m.sh` `VARTOTAL` | 0 | **0** (held) |
| `r10uvm23m.sh` | 36 | **36** (held) |
| `r10uvm28a` listing residue | 3663/3276/7941/3276 | **3663/3276/7941/3276** (held) |
| **`r10uvm41ts` named-typespec residue (NEW)** | 3864/3595/7988/3609 | **3862/3593/7986/3607** |

**0 movers**: all four UVM-4 rows stay `CMP_NOTEQUAL`. Every PRE number above
was re-measured on this box against a pristine-HEAD binary first and reproduced
pass 40's record **to the unit**, including `BINDWRONG`'s per-test split.

**The whole panel is FLAT and that is the correct outcome, not a null result.**
`uhdm-cmp` compares `VpiType` / `VpiName` / `VpiDefName` plus per-type extras;
a `SourceLocation` is not among them, and neither is a `vpiRange`. Every
existing metric projects onto compared fields, so **no existing probe could see
this defect at all** — which is exactly how it shipped. The evidence for the
fix is therefore (a) the `t58a` witness, (b) a NEW span-aware census, and (c)
the byte verifier's locality; all three are below.

New probe `tools/probe/r10uvm41ts.cpp`; one arm, `t58a`; drivers under
`tools/probe/r10uvm41repro/`. Reproduce:

    tools/probe/r10uvm41repro/probebuild.sh r10uvm41ts     # -> /tmp/r10uvm41_r10uvm41ts
    tools/probe/r10uvm41repro/gold58a.sh t58a /tmp/r10uvm41_g58a
    ~/git-repos/UHDM/build/bin/uhdm-dump /tmp/r10uvm41_g58a/slpp_all/surelog.uhdm

---

## 1. § sharedAliasNoStamp41 — the fix, and the three sites

> A typespec that `sharedAliasTs` can hand back is a **SHARED OBJECT**: it is
> the typespec of the TYPEDEF, and every declaration of that typedef's type
> points at it. A single USE of the type may **never** `setLoc`, `Instance` or
> `VpiSigned` it. Golden uses it exactly as it stands.
>
> The test is **POINTER IDENTITY against the typedef registries**, never the
> index type's canonical kind.

Golden, `t58a`, the promoted body-local `int ab[b8]` at line 51:

    |vpiIndexTypespec:
    \_ref_typespec:
      |vpiActual:
      \_bit_typespec: (b8), line:31:11, endln:31:20     <- the TYPEDEF's span

i.e. the shared object, at the typedef, with the typedef's own name and
`vpiInstance`. HEAD instead moves it to `51:12`, the `[b8]` bracket — and with
it every unrelated declaration in the design.

### The measured damage, and why the kind guard was never enough

`t58a` counts every occurrence of the two typedefs' typespecs in the dump:

| object | golden | HEAD `36b3234` | this pass |
|---|---|---|---|
| `bit_typespec (b8)` | 64 @ `31:11` | 15 @ `31:11` + **10 @ `51:12`** | **25 @ `31:11`** |
| `bit_typespec (pkb::b8)` | 29 @ `31:11` | 8 @ `31:11` + **13 @ `51:12`** | **21 @ `31:11`** |
| `int_typespec (myint)` | 32 @ `32:11` | 9 @ `32:11` + **6 @ `60:12`** | **15 @ `32:11`** |

Three things this table says that a narrower witness would not:

* **`myint` proves the kind guard was vacuous.** `typedef int myint` is
  canonically a `PredefinedIntegerType` and `isSigned()`, so it satisfied every
  clause of the guard that was supposed to protect shared objects.
* **BOTH shared objects are mutated**, the bare `b8` and the package-listed
  `pkb::b8` — the two registries (`typedefTs`, `pkgTopTypedefTs`) can each be
  the one `sharedAliasTs` returns depending on which listing is being emitted.
  So `isSharedAliasTs` tests **membership in EITHER registry**, not equality
  with `sharedAliasTs`'s winner; guarding on the winner alone would have left
  the other object mutable.
* A `b8` occurrence re-spanned at `51:12` includes a **module-level
  `pkb::b8 t`** and a package variable — declarations with no syntactic
  relationship to the array at all.

### Site 1 (the pass-40 defect) — `TaskFuncEmit.cpp` `makeAssocArrayVar`

The body-local arm. All three stamps now sit behind `!shared0`.

### Site 2 (INHERITED, and the one with corpus reach) — `UhdmExporter.cpp` `emitAssocDims`

**This was found by the witness, not by reading.** With site 1 fixed and site 2
still open, `t58a` came back dirty *in the same shape at a different line*:

    b8:      15 @ 31:11  +  10 @ 41:14      <- `b8 pmapb[b8];`  (the class property)
    pkb::b8:  8 @ 31:11  +  13 @ 41:14
    myint:    9 @ 32:11  +   6 @ 42:15      <- `int pmapi[myint];`

so the class-property path is reachable, was already wrong before pass 40, and
golden agrees with the same rule (`pkb::oobb::pmapb`'s `vpiIndexTypespec` is
`bit_typespec (b8) @31:11`). Both dimensions — outermost and inner — are
guarded.

**Its corpus reach is the whole of this pass's measurable effect.** The new
`r10uvm41ts` census (below) names it exactly, on SimpleUVM:

| object | HEAD span | span here | golden | fan-in |
|---|---|---|---|---|
| `bit_typespec 'uvm_pkg::uvm_reg_addr_t'` | `98:49` (`[uvm_reg_addr_t]`) | **`73:10`** | `73:10` | 39 |
| `bit_typespec 'uvm_reg_addr_t'` | `98:49` | **`73:10`** | `73:10` | 135 |
| `enum_typespec 'uvm_pkg::uvm_severity'` | `78:46` | `242:1` | `271:61`/`352:37` | 88 |
| `struct_typespec 'uvm_pkg::uvm_reg_map_addr_range'` | `99:46` | **`408:9`** | `408:9` | 9 |

Three of the four land on golden's span; **271 references** stop pointing at a
typespec spanned inside somebody else's index bracket. The `uvm_severity` row is
an honest residue and is written up in §4(2) — it was wrong before and is wrong
now, differently.

### Site 3 (INERT, guarded anyway) — `TaskFuncEmit.cpp` the assoc `io_decl` arm

The same `setLoc` + `Instance` idiom on an `assocIndexTs` result. It is the
`!named9` half of § `assocIoRange9`, so the index was written as a type
KEYWORD and can never resolve to a `TypeAlias`: **unreachable with a shared
object today**, and it is recorded as such in the code. The guard is there so
the invariant holds by `grep` at every `assocIndexTs` stamp site rather than by
re-deriving the grammar split each time. The fourth `assocIndexTs` caller
(`buildDynContainerTypedefTs`) stamps nothing and needs no guard, and the three
other `sharedAliasTs` consumers were audited: `StmtEmit`'s `foreach` loop-var
arm and `ModuleEmit`'s gen-scope enum arm only point a `ref_typespec` at the
object, and `TypeEmit`'s enum-base arm already takes a **shallow clone** — the
good-citizen pattern.

## 2. `tools/probe/r10uvm41ts.cpp` — why a new probe was needed

Every probe in the panel projects onto the fields `uhdm-cmp` compares, because
that is what a CMP campaign needs. A shared-object mutation is invisible there:
the object's kind, name and instance are all unchanged, only its span moves —
and it moves for *declarations the law never looked at*. `r10uvm41ts` prints one
line per NAMED TYPESPEC OBJECT (pointer identity, not `KIND:NAME`) with its
span, `vpiInstance` and **`ref_typespec` fan-in**, so a shared object stamped by
one of its users reads as a span that is not its typedef's, and the fan-in says
how many references were dragged along. Output is ordered by
`(line,col,kind,name)` — a total order, never first-hit, because
`Serializer::AllObjects` is a `std::map` keyed by POINTER.

## 3. § the refuted law — assoc INDEX name, `assocIndexAliasDefView41`, REVERTED

The one **cmp-relevant** residue this arm leaves was decoded and then its fix
was refuted, so it is written up rather than banked. `r10uvm40av`'s
`idx=<kind>'<name>'@<inst>` projection on SimpleUVM gives 21 assoc-index rows,
and **20 of the 21 already match golden to the row**:

    golden   3 x idx=bit_typespec'uvm_reg_addr_t'@uvm_pkg
    ours     3 x idx=bit_typespec'uvm_pkg::uvm_reg_addr_t'@uvm_pkg
    both     6 x idx=enum_typespec'uvm_pkg::uvm_severity'@uvm_pkg
    both     1 x idx=struct_typespec'uvm_pkg::uvm_reg_map_addr_range'@uvm_pkg
    both    11 x idx=class_typespec'<class>'@-

A packed-vector typedef has TWO named twins (`uvm_reg_addr_t` fan-in 135 and
`uvm_pkg::uvm_reg_addr_t` fan-in 39) and golden's index takes the BARE one,
while an enum/struct typedef index is package-qualified in golden too. The
obvious unifying rule — "take the DEF-view registry object, `pkgTopTypedefTs`
only as a fallback", which needs no kind test because an enum's DEF-view object
is itself `<pkg>::<alias>` — was implemented, built and measured, and is
**REFUTED**: it changed NOTHING, on `t58a` or on any of the UVM-4 census rows,
because both registries hold **the same package-qualified object** for these
typedefs (`ParamEmit` names every package typedef `prefix + ta.name`). The bare
twin that 135 references bind is minted somewhere else and has to be found
first. The law was reverted; only the registry-membership hardening of
`isSharedAliasTs`, which it motivated and which is needed for the invariant to
be complete, was kept. **The FINAL build was then re-gated in full** rather
than argued to be equivalent.

## 4. What is left, MEASURED

**(1) THE ASSOC-INDEX BARE-TWIN NAME, 3 rows, cmp-RELEVANT** — §3 above. The
only cmp-compared difference this arm still has, its census is one line wide,
and its first candidate mechanism is already refuted for the next pass. Find
where the bare-named twin with fan-in 135 is minted (it is NOT
`ParamEmit`'s package-typedef pass; every object there is `prefix + name`).

**(2) the `uvm_severity` span, dump-only, and a WARNING about the shape of the
law** — golden's two `enum_typespec 'uvm_pkg::uvm_severity'` objects are spanned
at `271:61` and `352:37`, both of which are `[uvm_severity]` INDEX BRACKETS in
`uvm_report_server.svh`, *not* at the enum declaration `242:1`. So Surelog
itself hands back an enum typespec spanned at a use — i.e. "the shared object
keeps its typedef's span" is the rule for a packed-vector and a struct typedef
and is NOT the rule for an enum one. HEAD had it at `78:46` (a different use)
and this pass has it at `242:1` (the declaration); both are wrong, neither is
cmp-relevant, and **the arm must not be generalised into "always the
declaration" without measuring the enum half.**

**(3) DETERMINISM — `Scoreboard`'s `default` database is NONDETERMINISTIC, on
BOTH builds, and any byte verifier has to know it.** Measured with `jobs 1`, so
it is not sweep parallelism: 4 sweeps of the HEAD binary give
`dc07ffea…`/`dc07ffea…`/`7da3e61a…`/`dc07ffea…` and 4 of this build give
`ae99f341…`/`86148468…`/`86148468…`/`ae99f341…` — two hashes each, alternating.
`SeqDriver`, `SimpleUVM` and `BuildUVMPkg` are byte-stable run to run on both.
This is the recorded macro-buffer `SourceLocation` flake, PRE-EXISTING and not
introduced here; the CSV verdict (including the DUMP column) was stable across
every run. Consequence for the method: **a byte verifier cannot claim identity
for `Scoreboard`**, and a future pass that byte-compares it must sample at
least two runs per binary before calling a difference a change. Nothing this
pass emits iterates a pointer-keyed container: both guards only SUPPRESS writes
on the ordinary emission walk.

**(4) carried, unchanged by this pass** (pass 40 §4 still reads true): the
MODULE-IMPLICIT-NET arm, which owns the whole of `BINDTOTAL`'s disclosed +4 and
whose trap is that `r10uvm28m` keys on a SET of actuals; `BARE -> SELF` 438
rows, homogeneous PER ROUTINE; `BINDWRONG`'s 342 owner-attribution
`Z-multiobj` rows and the 82 parameter-vs-folded-constant rows; the
`IOTOTAL2`=3 POPULATION row; the MODULE arm of § `classKeyTsScopeOwner35`; the
socket sharing residue; `INITTOTAL`-52; t40a; `r10uvm23m` var=34; t36b; t33d.

## 5. Gate

Every gate was run with `SLANG_UHDM` pinned to **this worktree's own** binary
(`verify_golden.py:52` and `tests/check_goldens.sh:5` both default to the
MAIN-TREE binary and a false pass is indistinguishable from a real one), and
the whole panel was re-measured on this box against a pristine-HEAD build
first.

* goldens **23 PASS / 0 FAIL**
* u2r `testflags`: **byte-identical** to `results/gate_uhdm2rtlil.csv`
  (732 lines, 679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`)
* Surelog both modes: **byte-identical** to `results/golden_surelog.csv`
  (1589 rows, whole row incl. DUMP), `SLANG_REJECT` membership unchanged, no
  pinned giant flaked
* **byte verifier** — the whole-row CSV diff is BLIND inside the 27 rows that
  are already `CMP_NOTEQUAL`, so every `slang.uhdm` the both-modes sweep emits
  was hashed, HEAD vs patched, **both runs writing to the SAME workdir path**:
  **953 databases, 946 identical / 7 differ, and the 7 are EXACTLY the 7
  comparable UVM-4 rows** (BuildUVMPkg, Scoreboard, SeqDriver, SimpleUVM
  `default` + BuildUVMPkg, SeqDriver, SimpleUVM `testflags`; Scoreboard's
  `testflags` row is `SLANG_REJECT`). This is the sharp negative control a
  span-only law needs, since it could have moved the DUMP column anywhere.
  Caveat recorded honestly: `Scoreboard default` would have differed anyway
  (§4(3)); the other six are real.
* the HEAD half of that run doubles as a **baseline-validity** check: its own
  CSV is byte-identical to the committed `results/golden_surelog.csv`, so the
  committed baseline is reproducible on this machine.
* the FINAL build (after §3's revert) carried goldens, u2r and the Surelog
  both-modes gate again in its own right.
