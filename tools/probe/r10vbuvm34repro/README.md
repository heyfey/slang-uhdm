# r10vbuvm34 — the ADVERSARIAL VERIFICATION of § foreachScopedArrayLoopVarIntFallback34

**VERDICT: ACCEPT WITH FIX.**  The production surface is BYTE-IDENTICAL to the
implementer's (`src/StmtEmit.cpp`, +41/−1, one logic change).  The fix is
documentation only: three passages of the pass's own `README.md` stated a
residue rule (`R1`) that this verifier's `v34g` arm MEASURES to be false, and
one (`R3`) that understates its own width by an order of magnitude.  Nothing
executable moved, so every gate below still holds bit for bit.

Everything here was re-measured from scratch: both binaries were built by this
verifier in its own worktrees at `bd8cbb7`, and **both md5s came out
bit-for-bit identical to the pass's** (`d294370b…` pristine,
`ab753ec4…` patched), so the build is reproducible from the patch alone.

---

## 1. What was reproduced, bit for bit

Every headline number in the pass's report was re-derived independently and
matched: the 56→17 head movement on six row-modes, the head's decode, the
census (4554/890 → 4560/884, `ascoped=Y` 7/6 → 13/0, NEW 0 / GONE 6,
TO-GOLDEN 6 / AWAY-GOLDEN 0), the judge-visible split (828 span-only,
62 → 56), the 6/956 and 0/1358 movers with the 48 attributed lines, the
`cmds.txt` audit (1523/50 and 1458/4), the corpus status histograms and the
whole canary/protected-database battery.  `GATES.txt` carries the numbers.

The **mover prediction was made independently**, from the PRISTINE databases,
with this verifier's own predicate — an OUR-side `FELV` row whose golden
`ascoped=Y` and whose loop-variable kind is neither `int_var` nor the
unresolved `ref_var` — and it named the same six databases the pass named, and
only those.  `byteverify.sh SELFCHECK=1` then measured exactly that set.

The head was decoded from this verifier's OWN pristine cmp log, not carried
forward: `LHS: int_var (…::init_sequence_library::i)` @496:44-496:45 with
`ref_typespec -> int_typespec`, against `RHS: array_var` + `array_typespec` —
same `vpiName`, same span, same `vpiParent`.  The KIND and, through
`ref_typespec::Actual_group`, the typespec kind are the whole disagreement.
`R0` was decoded the same way and confirmed: `LHS: <null>` with a full RHS is
the SINGULAR overload's MIRROR, so **ours** carries the `vpiTypespec` golden's
`vpiOpType:67` operation lacks — and **Scoreboard/default's head is that same
object in BOTH sweeps**, not the `logic_net work@top.p` that §3b records.  The
pass's proposed §3b correction is measured-correct.

---

## 2. Breaking the law — 21 arms, 2 views, 2 families, BROKEN = 0

`vdump34.py` is an INDEPENDENT reader of `uhdm-dump` text (it does not use the
pass's C++ census at all).  It parses the indentation tree, **skips every
`vpiParent:` subtree** — the dump renders one level of the parent inline and a
naive walk double-counts it — and emits two MULTISET families:

* `FELV` — one row per (`foreach_stmt`, loop-variable SLOT).
  KEY = (source `line:col`, SLOT, loop-var `vpiName`); PAYLOAD = the loop
  variable's KIND, its ACTUAL typespec's KIND / NAME / **own SPAN** /
  **`vpiSigned`**, and the ARRAY reference's KIND / `vpiName` /
  `Path_elems` count and kinds.
* `REFB` — one row per body reference whose `vpiName` is a loop-variable name;
  PAYLOAD = bound? + the bound object's KIND.  **This family exists because
  the patch changes `declLoopVar`'s RETURN in a non-package home** (the tail
  gate registers only `int_var` / `array_var` / `assocIdx19` / `res22`, so a
  cell that used to yield a `string_var` or `class_var` now registers and its
  body references bind).  A listing-only comparator would be blind to it.

The KEY never carries the parenthesised `vpiFullName` (no generated `Compare`
reads it) and never keeps a per-line first/last writer.  `vscore34.py` votes
SAME / FIXED / RESIDUE / **BROKEN** per key and also reports an order-blind
MULTISET DISTANCE to golden for each side.

**POSITIVE CONTROL** (the scorer must be able to see a regression): mutating
ONE loop-variable kind in the patched `g34a1` dump on a cell pristine got RIGHT
turns the verdict into `BROKEN=1` and raises `dist(G,PAT)` 4 → 6.  Mutating a
cell pristine got WRONG moves it FIXED → RESIDUE instead.  The column is live.

**Result over 21 arms × 2 views × 2 families = 84 scored rows (`ARMS.txt`):**

```
BROKEN = 0 in every row.
distance to golden:  BETTER 67   SAME 17   WORSE 0
```

The seven new adversarial arms (`v34a`…`v34g`) and the fourteen re-run arms
(`g34a1-3`, `g33a1-3`, `v33a-d`, `vg19c`, `vg19d`, `vg25`, `g25`) cover:

| arm | what it breaks |
|---|---|
| `v34a` | the **NON-CLASS `::` face** — a PACKAGE-qualified `pv34::<arr>` over all thirteen array types, in a package function, a package task and a module initial, each with a bare twin |
| `v34b` | the **BINDING face** — the loop variable USED in RHS / LHS index / call argument / condition / concat member / binary operand, and UNUSED, in a module, an interface and a program home, 3 instances |
| `v34c` | **generate-for / generate-if** homes, a class declared in `$unit`, a module with the IDENTICAL text as a twin, 1..3 instances, and a loop variable that SHADOWS a class property |
| `v34d` | array of UNPACKED structs, array of PACKED structs, queue-of-queue, `[4][string]`, `[string][string]`, array of class handles, and `protected` / `local` / `static` / `const` properties; a class declared inside a MODULE |
| `v34e` | NESTED foreach re-listing the same name, a static method, an in-body method, `fork…join_none`, inside `for` / `while` / `always`, three identical instances of one statement |
| `v34f` | `$unit::C::m`, `pkg::C::m` (THREE segments), a TYPEDEF-ALIAS qualifier, and a PARAMETERISED SPECIALISATION qualifier `outer34#(8)::` |
| `v34g` | interface vs program × INSTANTIATED vs NOT, text held constant |

### What the adversarial arms found

1. **The law generalises to a PACKAGE qualifier** (`v34a`).  Golden answers the
   bare `int_var` + `int_typespec` for `pv34::ps34` (queue of string),
   `pv34::pc34` (queue of class), `pv34::pe34q` (enum), `pv34::pp34` (packed
   struct) and `pv34::pv34v` (packed vector) exactly as it does for a class
   qualifier.  21 FIXED cells; `dist` 70 → 28 def, 200 → 84 elab.
2. **…and to a three-segment path, a typedef-alias qualifier and a
   parameterised specialisation** (`v34f`): `pf34::inner34::iq34`,
   `alias34::iq34`, `outer34#(8)::oq34` are all golden `int_var`, all FIXED.
3. **…and to an INSTANTIATED interface and an INSTANTIATED program** (`v34g`) —
   see §3.
4. **The binding change is in the right direction.**  `REFB` never regressed
   and improved on eleven arm-views (e.g. `g34a2` 22 → 0 def and 90 → 0 elab,
   `v34b` 70 → 4 elab, `v34d` 68 → 0 elab).
5. **A cell the pass's own comparator could not see is an improvement.**
   `vg19c`'s package-qualified header used to share the DECLARATION's spanned,
   `vpiSigned:1` `int_typespec`; golden mints a BARE one, and the patch now
   does too.  It only shows once the typespec's own span and `vpiSigned` are in
   the payload — which is why they are.

---

## 3. THE ONE CORRECTION — `v34g`: it is INSTANTIATION, not the home kind

The pass's residue R1 read *"the INTERFACE and PROGRAM homes resolve NOTHING in
golden"*.  `v34g.sv` holds the text constant and varies only whether `topg34`
instantiates the unit:

| home | instantiated? | golden, SCOPED cell | patched |
|---|---|---|---|
| `interface ifI34` | **yes** | `int_var` + bare `int_typespec` | **matches (FIXED)** |
| `interface ifU34` | no | unresolved `ref_var` | `int_var` (residue, distance unchanged) |
| `program pgI34` | **yes** | `int_var` + bare `int_typespec` | **matches (FIXED)** |
| `program pgU34` | no | unresolved `ref_var` | `int_var` (residue, distance unchanged) |

So an interface home and a program home are IN this law whenever the unit is
elaborated at all, and R1 is really *"a unit that is never instantiated is
never elaborated, so `writePackage`/`lateTypedefBinding` never runs over it"* —
§ foreachLoopVarObjs9's R3 reaching an unelaborated unit.  The pass's README
has been corrected in place, and the residue's SIZE claim (38 of the 56
remaining judge-visible cells are homed in `work@svaunit_vpi_interface`
functions of MiniAmiq) was re-measured and is right.  Those 38 are BARE
spellings, so they are outside this law's face either way.

---

## 4. Gates and boundary

`GATES.txt` — the whole battery, re-run.  `BOUNDARY.txt` — four boundary
configurations over a COPY of the whole probe tree with an RC LEDGER for every
cell, `PROCESSED == LISTED == LEDGER` everywhere, `asym.txt` never written,
**0 unattributed ADDED lines** in either view, and the three dir-only differs
(`r10uvm75repro`, `r10uvm76repro`, `r10v109repro`) proved COINS by a
same-binary-twice control (`vcoin34.sh`): the pristine binary against ITSELF
differs 6–28 raw lines and 0 order-blind, in both views.

No bind-window directory appears in any differ list, in either mode, in either
view: `classArgBind12`, `retNameRecvCollapseArgsBindLikeBody15`,
`collArgNamedBlkLocalNoBind15`, `controlBodyNoBind28`,
`blkLocalSameCtrlDepthArgBinds57/64`, `pkgVarBindsOnlyThroughInstance88`,
`formalDefaultBindsLikeBody13`, `classInBodyRecvCallArgNoBind52`,
`superNewFormalBinds28`, `newArrayArgNoBind16`, `namedTfArgsFormalSlots4`,
`writtenCallArgs16`, `genLpPortConnCopyableOnly11v`, the uvm89/92/94/95
name-text arms, the uvm90/96 cast arms, buvm24/26/27/28's arms and the sd8-12
subdirectory arms are all byte-identical between the two binaries.

---

## 5. Ranked residues this verification adds

* **R-V1 — `$unit::C::m` is not recognised as a scoped spelling** (`v34f` F1/F2).
  Golden's array reference is `class_var '$unit::uarr34'`; ours is a plain
  `ref_var 'uarr34'`, because `foreachScopedArrayName33`'s leftmost-segment
  walk needs an IDENTIFIER and a `$unit` scope token is not one.  This is a
  § foreachScopedArrayWrittenClassVar33 (pass 33) residue, identical in
  pristine and patched.  The loop variable happens to be `int_var` on both
  sides already, so it is invisible to THIS law and shows only on the array
  reference.  Corpus incidence: zero (`ascoped=Y` is 13 cells, all
  `this_type::…`).
* **R-V2 — the package-level BARE face is a 13-cell residue, not a 1-cell one**
  (`v34a`, folded into the pass's R3).  Golden gives `array_var` + a bare
  `array_typespec` to EVERY non-associative package-level array and keeps the
  typedef's NAME on a typedef'd one; we drill to the element in ten of
  thirteen.  Unchanged by this pass; the natural next widening of
  § foreachPkgClassArrayVar25.
* **R-V3 — the NESTED foreach re-listing the same loop-variable name**
  (`v34e` N2, `@15:9`).  Golden lists a named `ref_var` for the re-listed slot;
  the `openForeachVars` arm pushes the OPEN object, which the dump shows with
  no `vpiName` of its own at that slot, and the elaborated view lists it once
  where golden lists it twice.  Identical in pristine and patched.
* **R-V4 — a module home's body reference binds the implicit net where golden
  binds nothing** (`v34b` `@60:35`, an uninstantiated program).  Pre-existing,
  identical in pristine and patched.

---

## 6. Files

* `vdump34.py` — the independent `uhdm-dump` reader (`FELV` + `REFB`).
* `vscore34.py` — SAME / FIXED / RESIDUE / **BROKEN** + order-blind distance.
* `vall34.sh` — score every arm workdir, both views, both families.
* `varm34.sh` — one arm, both views, THREE sides (golden / pristine / patched),
  every command and rc echoed into `cmds.txt`.
* `vbound34.sh` — the boundary gate with an RC LEDGER for every cell.
* `vcoin34.sh` — the same-binary-twice nondeterminism control.
* `v34a.sv` … `v34g.sv` — the adversarial arms.
* `ARMS.txt`, `GATES.txt`, `BOUNDARY.txt` — the measurements.
