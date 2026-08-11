# r10uvm49 — a MEASUREMENT-ONLY pass. NO production code. Read this before pass 50.

**The implementing agent died on a transient API 529 during the arm-reading phase,
before writing any emitter code.** Its worktree's `src/ParamEmit.cpp` and
`include/UhdmExporter.h` are byte-identical to pristine `133f5ee`. The verifier
proved that rather than assuming it, then converted its own budget into
measurement — and what it measured **REFUTES THE CENTRAL HYPOTHESIS OF THE
MASTER'S PASS-49 BRIEF**. That refutation is the product of this pass, and it is
worth more than the law would have been, because a pass-50 implementer following
the brief would have "fixed" code that is already correct.

`README.verifier.md` beside this file is the verifier's full write-up. Everything
below is what the MASTER re-measured personally at `133f5ee`, with the commands,
because a claim that reverses a brief has to be checked by the person who wrote
the brief.

LHS is ALWAYS golden(Surelog). RHS is ALWAYS ours.

## 1. GOLDEN PICKS THE BASE BY **NAME ORDER**. My "source-first" model is REFUTED.

I briefed: *"NAME ORDER IS NOT GOLDEN'S RULE — golden uses the SOURCE-FIRST
typedef ... BUILD THE ARM WHERE SOURCE ORDER AND NAME ORDER DISAGREE ... that
single cell decides whether you are fixing a real bug or preserving a
coincidence."* The arm was built, and it says the opposite of what I predicted.

Arm `a1` (`bash gold.sh a1 /tmp/v49_a1 <binary>`), source:

    line 15:   typedef gc49#(string, int) zzz_first_t;    <- SOURCE-first, name-LAST
    line 16:   typedef gc49#(string, int) aaa_second_t;   <- source-second, NAME-first

Golden gives **BOTH** objects `line:16:11` — line 16, the **NAME-FIRST** typedef:

    \_class_typespec: (p49a::aaa_second_t), line:16:11, endln:16:15
    \_class_typespec: (p49a::zzz_first_t),  line:16:11, endln:16:15

Arm `a3` settles it with source order **fully reversed** — source is `zzz_3_t`
(14), `mmm_3_t` (15), `aaa_3_t` (16) — and **all three** carry `line:16:11`, i.e.
the alphabetically-first name, which here is the source-**LAST** declaration:

    class_typespec: (p49c::aaa_3_t), line:16:11
    class_typespec: (p49c::mmm_3_t), line:16:11
    class_typespec: (p49c::zzz_3_t), line:16:11

**CONSEQUENCE: DO NOT TOUCH the name-order comparison at
`src/ParamEmit.cpp:19047-19049`. It is CORRECT.** The in-tree comment at
`19036-19039` already said "the name-first of the typedefs that share it" — the
code was right and the brief was wrong. The BuildUVMPkg corpus case coincides
either way (`uvm_id_actions_array` sorts before `uvm_id_verbosities_array`), which
is exactly why only a disagreeing arm could settle it.

Alias topology, from `a1`/`a3`: **FLAT**. Every non-base name aliases DIRECTLY to
the base and the base itself carries no `vpiTypedefAlias`. There is no chaining
through intermediate names — another thing my brief listed as unmeasured and
guessed the harder way round.

## 2. The real defect is NARROWER than I said — rule (3) of the brief is ALREADY DONE

I briefed that "parented at the importing container ... is the NEW HALF this pass
must add". It is not: **our typedef PUBLICATION already matches golden
object-for-object, base choice and container parent included.** What differs is
the *declaration* site. In `a1`, for `class_var (p49a::holder49::hz)`:

    vpiTypespec -> ref_typespec -> vpiActual:
      GOLDEN: class_typespec (p49a::zzz_first_t), line:16:11, endln:16:15
      OURS:   class_typespec (gc49),              line:19:5,  endln:19:16

identical in shape to the corpus head (`uvm_id_verbosities_array` @29:9 vs
`uvm_pool` @62:3, ours parented at the `class_var`). So the law pass 50 needs is:

> **a declaration whose type names such a typedef must POINT AT the typedef's
> existing per-name object, not MINT a declaration-site `class_typespec` named for
> the generic class.** Direction: REPLACE. Fix = point at existing, not mint.

## 3. Rule (4) CONFIRMED, and it has a THIRD spelling I never stated

The container-prefix rule holds, and the joiner depends on the container KIND:

| container | joiner | golden | ours |
|---|---|---|---|
| `package` | none (the prefix already ends `::`) | `uvm_pkg::` + `uvm_pkg::uvm_id_…` | **same** |
| `module_inst` | `.` | `work@top_tb.uvm_pkg::uvm_id_…` | `p49a::p49a::…` **WRONG** |
| `class_defn` | `::` | `work@env::uvm_pkg::uvm_id_…` | `p49f::p49f::…` **WRONG** |

I spelled out only the module and package cases; the **class** container takes
`::` and is **3 of the 7 comparable rows**. `src/ParamEmit.cpp:19068` is literally
`prefix + prefix + …`, which is right only for the package case. I confirmed the
module joiner myself in `a1`'s golden: the ref_typespec fullname is
`work@a1_top.p49a::zzz_first_t` — container + `.` + package-qualified name.
**This is `vpiFullName`-only, so it is NOT cmp-visible** — DUMP_MATCH phase-3
work, not conversion work.

## 4. TRAP FOR PASS 50: every arm is CMP_EQUAL **while carrying the defect**

`a1` reports `cmp rc=0, cmp lines=0, heads=0` — and I reproduced that myself —
yet its dump carries the defect in full. Two independent reasons, both already
named in this campaign's law list:

* `BaseClass::Compare` never reads `VpiFullName`, so the whole of section 3 is
  invisible to cmp.
* golden's object is reached FIRST through the container's `vpiTypedef` list,
  where it pairs against our identical object and compares EQUAL, so
  **`m_visited` short-circuits** the later visit through `hz` and returns 0
  without ever looking at our `gc49`.

**JUDGE THESE ARMS ON `diff -u g.dump o.dump`, NEVER ON `cmp.txt`.** This is the
third appearance of the m_visited hazard (see pass 47's
§ ifaceDupSharesHomePorts and pass 48's renamed index).

## 5. UNTESTED CELL, and it is the corpus shape

In `a1` the module imports the package DIRECTLY. SeqDriver has `module top_tb`
over `package adpcm_pkg` which imports `uvm_pkg` — a **TRANSITIVE RE-EXPORT**, and
golden's `vpiInstance` there is the INTERMEDIATE package (`adpcm_pkg`), not
`uvm_pkg`. Build that arm before writing emitter code.

## 6. MY CITATIONS WERE INCOMPLETE IN A SAFETY-CRITICAL WAY — verified by me

My brief listed 6 `typedefTs`/`pkgTopTypedefTs` write sites. **There are 13**
(`grep -nE '(typedefTs|pkgTopTypedefTs)\[[^]]*\] *=' src/ParamEmit.cpp`):

    17589 17594 17596 17612 17894 18006 18070 18129 18218 18642 18654 19024 19026

The two I missed are the load-bearing ones. **`19024` and `19026` register those
typespec pointers in the shared tables, and then `19061-19065` MUTATES THE SAME
OBJECTS' LOCATIONS IN PLACE** — `VpiLineNo`/`VpiColumnNo`/`VpiEndLineNo`/
`VpiEndColumnNo`/`VpiFile` all copied from `bts9` — and there is **no
`isSharedAliasTs` call anywhere in `19023-19072`** (nearest is `20290`; declared
`include/UhdmExporter.h:3098`, defined `src/UhdmExporter.cpp:1094`). I checked all
three facts myself.

**The precise status, which matters more than the alarm:** that mutation is how
golden's "every clone carries the base's line" is reproduced, and it is SAFE TODAY
only because each `cts9` is freshly minted per typedef (`MakeClass_typespec()`
just above the `pkgClassTd9.push_back` at `18953`). The hazard is that the objects
are now IN the shared tables, so any pass that starts reaching them THROUGH those
tables and mutating them — or that makes `cts9` shared rather than per-typedef —
breaks a different consumer with no guard to catch it. Pass 50 edits exactly this
region.

Two smaller citation fixes: the alias block is `19040`-**`19072`**, not
`19040-19070`, and it is **TWO** loops (`19042` and `19052`), not one. Exact and
confirmed: `pkgClassTd9` declared `16985`, filled `18953`, name-order pick
`19047-19049`, doubled fullname `19068`, `Typedef_alias(art9)` `19070`.

## 7. The grouping key is the GENERIC CLASS, not the specialisation

Arm `a4`: Surelog groups **genuinely different** specialisations
(`gc49#(string,int)` and `gc49#(int,string)`) under ONE base. So my explanation
that the three UVM typedefs collapse "because `uvm_action`, `UVM_FILE` and `int`
are all int typedefs, so all three are THE SAME specialisation" is not the
operative rule — the collapse would happen even if they were different
specialisations. Getting the right answer for the wrong reason is still a wrong
model, and it would have mis-shaped the gate.

## 8. State of the four tests — UNCHANGED, and re-measured

All four still `CMP_NOTEQUAL` (Scoreboard/testflags `SLANG_REJECT` at baseline);
7 comparable rows; 50 cmp lines and exactly 1 head each (`grep -c '^LHS:'`). The
id-normalised head md5 is identical ACROSS MODES per test and DIFFERS BETWEEN
tests — the four share one *law*, not one byte string:
`BuildUVMPkg 65e682317a01`, `Scoreboard 8b6c80911ce8`, `SeqDriver d0133c2a250a`,
`SimpleUVM 94e68124ad89`.

The verifier's `heads.sh` is worth reusing: it **refuses to print a number it
cannot substantiate**, and that guard fired for real — it first reported
`measured=0 skipped=8` because the golden cache path is a DIRECTORY, which in an
unguarded driver is precisely the failure that reads as perfection.
