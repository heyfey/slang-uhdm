# r10uvm46 — UVM pass 46

**TWO laws, both from the handoff's ranked list, both decoded to their Surelog
line and both measured on purpose-built arms before a line of emitter code was
written. Three headline metrics CLOSED:**

| metric | pass 45 committed | HEAD re-measured | this pass |
|---|---|---|---|
| **`LSTOTAL`** | **3 (2/0/0/1), scope 3** | **3 (2/0/0/1), scope 3** | **0 (0/0/0/0), scope 0** |
| **`IOTOTAL2`** | **3** | **3** | **0** |
| **`IOTOTAL`** | **2** | **2** | **0** |
| `r10uvm23m` | 36 | 36 | **34** (`tf` 2 -> 0) |
| `BODYOTHER` | 435 | 435 | **434** |
| `CPTOTAL` | 580 (145/67/299/69) | 580 | 580 unchanged |
| `LISTDIRECT` | 80 (22/18/22/18) vs golden 56 | 80 | 80 unchanged |
| `BINDWRONG` | 757 (43/87/521/106) | 757 | **757, no sub-class moved** |
| `BINDTOTAL` | 1681 = 938 extra / 743 miss | 1681 = 938/743 | unchanged — extra did not grow, miss did not grow |
| `r10uvm42tw` | 3863/3581/8148/3595 | same | unchanged |
| `r10uvm41ts` | 3827/3555/7974/3569 | same | unchanged |
| `r10uvm28a` | 3663/3276/7941/3276 | same | unchanged |
| `PAIRTOTAL` / `VARTOTAL` / `CTORTOTAL` | 0 / 0 / 0 | 0 / 0 / 0 | 0 / 0 / 0 |
| `INITTOTAL` | 52 | 52 | 52 |
| `TSINSTTOTAL` / `CPCLASS` | 1074 / 25 | 1074 / 25 | 1074 / 25 |
| the 7 comparable UVM-4 rows | unchanged | unchanged | unchanged |

Conversions: **0**. All four UVM-4 tests stay `CMP_NOTEQUAL` and uhdm-cmp's first
unequal pair on all four is still a `decompile:` difference. What moved is that
**every listing and io residue the panel tracks on the UVM-4 is now zero** — the
listing vector is the first thing cmp reads, and `BuildUVMPkg`'s entire known
residue was ONE object.

## 0. The three checks the handoff demands BEFORE ranking — answered up front

| | ranked #1 (SimpleUVM's missing `interface_inst`) | ranked #2 (BuildUVMPkg's `ceil`) |
|---|---|---|
| **(a) shape present**, selective census with a positive control | **YES** — `r10uvm46if` (new): golden holds 3 `interface_inst` objects, we hold 2, and the census names the missing POSITION (`work@top`/top `Interfaces` n=1 vs n=0). Positive control: the probe REFUSES to print when a database holds zero `interface_inst` objects, and that refusal actually fired on `BuildUVMPkg` (no interfaces there at all) — so a zero from it is a measurement, not a blind spot. | **YES** — `r10uvm46tf` (new) walks the SERIALIZER, not the class listing: golden has ONE empty-named, zero-formal `function` in `uvm_pkg::uvm_reg_map` where we have `'ceil'` with 2 formals and a body. The listing alone could not have answered this: `vpiTaskFunc` is built from a NAME-KEYED map, so any number of unnamed methods collapse onto one entry (t64a: six methods, one entry). |
| **(b) tests comparable** | **YES** — `SimpleUVM` is `CMP_NOTEQUAL` in BOTH modes (2 of the 7 comparable UVM-4 rows), not `SLANG_REJECT`/`TIMEOUT`/`DEFERRED`. | **YES** — `BuildUVMPkg` is `CMP_NOTEQUAL` in BOTH modes. |
| **(c) golden's side populated** | **YES** — golden's `work@top`/top holds the object; and the position it sits in is one we already fill correctly for the other view. | **YES** — golden holds an OBJECT there (`function ''`, `ret=SET`, `method=1`, `vis=3`), it is not an absence. |

**The identity check the handoff called the highest-leverage one is CONFIRMED:
`ceil` is ONE object behind FOUR metrics.** Not asserted — read off the residue
rows themselves:

    LSTOTAL        647d646  < task_func '' n=0        /  956a956  > task_func 'ceil' n=0
    r10uvm23m tf   2645c2645 < ELABPKG[uvm_pkg]::uvm_reg_map tf function ''
                             > ELABPKG[uvm_pkg]::uvm_reg_map tf function 'ceil'
    IOTOTAL        3446a3447,3448  > ELABPKG uvm_pkg::uvm_reg_map::ceil io[0] 'a' …
                                   > …                                   io[1] 'b' …
    IOTOTAL2       6271c6271 < ELABPKG uvm_pkg::uvm_reg_map:: io[-] <none>
                             > …::ceil io[0] 'a' …  > …::ceil io[1] 'b' …

## 1. § bindIfaceTwinInParent46 — a `bind` interface is published TWICE

`src/ModuleEmit.cpp` (the interface-child site in `emitInstance`, the
`Interfaces` install site, and two new helpers), `include/UhdmExporter.h`.

Two Surelog sites, one source instance:

* `DesignElaboration::createBindInstance_` builds the bind instance with
  **`parent->getParent()`** as its parent — the TARGET's parent, not the target.
  So its full path drops the target component: `work@top.add_sub_if0`, never
  `work@top.dut.add_sub_if0`. Its nets and variables keep the target-based path,
  so only the interface object's own `VpiFullName` moves. When the target has NO
  parent (it is itself a top-level instance) the same function re-parents onto
  the TARGET, which is why `InterfaceBinding` reads `work@ADD_SUB.add_sub_if0`.
* `NetlistElaboration::elaborate_` self-registers an interface-type instance into
  **its parent's** `netlist->interfaces()` (`elab_interface_(instance->getParent(),
  …)`), and `UhdmWriter::writeInstance` attaches that vector to the parent — a
  SECOND `interface_inst` object for the one source instance.

### The 2x2 the handoff asked for, plus two cells it did not — every one read on golden BEFORE coding

| cell | arm | golden | our HEAD |
|---|---|---|---|
| target instantiated, ONE copy | `t63a` (= `SimpleUVM` with the UVM removed) | twin in the target's PARENT: `work@t63a`/top `Interfaces` n=1 | n=0 |
| target NOT instantiated (it is a top) | `t63b` + corpus `InterfaceBinding` | **NO twin**, 2 objects | 2 — already equal |
| target instantiated TWICE | `t63c` | parent lists `add_sub_if0` **TWICE** (n=2): the twin is per ELABORATED COPY | n=0 |
| **target nested TWO levels down** | `t63d` — **the discriminator** | twin in `work@t63d.mid`, **NOT** in the top: the holder is the target's PARENT, not the design top | n=0 |
| **parent instantiates an interface of its OWN** | `t63e` — **the suppression** | **NO twin at all**; the parent lists only `own_if` | **NOT already equal — see below** |
| **the twin's CONTENT** | `t63f` (one of everything) | ports, modports, variables, parameters, param_assigns — and NO nets, NO cont_assigns, NO processes, NO task_funcs, NO clocking blocks | — |

**CORRECTION FROM THE PASS-46 VERIFIER — this pass UNDER-claimed `t63e`.** The
table above called `t63e`'s HEAD column "already equal". It was not: `t63e`'s
interface census against golden was **6 diff lines at HEAD and is 0 after this
patch**, so the suppression cell is a cell this pass FIXED, not a cell that was
already right. Recorded because the campaign's failure mode runs the other way —
an under-claim hides a working law from the next pass's ranking exactly as
effectively as an over-claim invents one. (`t63e` remains `NOTEQUAL` overall on
an unrelated pre-existing `decompile:` residue whose cmp output is byte-identical
to HEAD's, 1202 bytes — which is what made the census improvement easy to miss.)

`t63e` is why "just publish the twin" would have been wrong in half the cases:
`writeInstance` attaches `netlist->interfaces()` and then its child walk builds a
FRESH vector for the holder's own interface instantiations and **overwrites the
field** (the netlist branch declares a shadowing local, so the outer
`subInterfaces` is still null at the child walk). The twin is then unreachable
and `Serializer::GarbageCollect` deletes the object. That also resolves the
apparent contradiction in `InterfaceBinding`, where both publications land on the
same holder and only one object survives.

`t63f` decided the content, and `r10uvm46if -p` decided the SHARING: the twin
holds the **same port and variable OBJECTS** as the instance it twins
(`P[0x853ede0,…]` identical, `V[0xeec3650]` identical), in fresh vectors. So the
law shares and **mutates nothing** — golden's shared children keep their
`VpiParent` on the target's object (the `bit_var` under `work@top`'s twin still
parents at the `work@top.dut` object), and re-stamping them would move a compared
field on objects another view owns.

**Post, on the final binary:** `t63a`-`t63f` all have a ZERO interface-census diff
against golden; `t63a`/`t63b`/`t63d` are `uhdm-cmp` EQUAL (`t63a` was NOTEQUAL at
HEAD, 56 KB of diff; `t63c` went 105,696 bytes -> 1,320). `t63c`/`t63e`/`t63f`
remain NOTEQUAL on a PRE-EXISTING, unrelated `decompile:` residue — byte-for-byte
the same cmp output as at HEAD for `t63e` (1202) and `t63f` (1334), so this law
neither caused nor fixed it. Corpus: `SimpleUVM`'s census is now IDENTICAL to
golden in BOTH modes (objects and container positions), and `LSTOTAL`'s SimpleUVM
entry — a whole missing listing SCOPE — is gone.

**Deliberately excluded, because no golden was read for them:** an INSTANCE-PATH
target (`bind $root.top.foo_i …`) and a bind nested in a GENERATE scope, both of
which the module arm already treats specially. And a holder that is a `gen_scope`
or an `interface`: the twin is recorded against the holder and simply never
claimed, which leaves those paths byte-identical to pass 45 rather than guessing.

## 2. § qualifiedLifetimeMethodLosesNamePortsBody46 — and BOTH handoff candidates are REFUTED

`src/TaskFuncEmit.cpp` (the predicate next to `qualCtor27`, the name/fullname, the
return var, the io attach, the body).

The handoff named two candidate distinguishers for `ceil`: the `local` qualifier
and the two-token return type `int unsigned`. **Arm `t64a` refutes both**, with
controls in the same class: `local` alone is named (`f_loc_2tok`, `f_loc_1tok`),
`int unsigned` alone is named (`f_auto_2tok`, `f_2tok`). The real distinguisher is
the PAIR **(any class-item qualifier) + (an explicitly written LIFETIME)**, and it
is a two-line source read:

* `CompileClass::compile_class_method_` hands `compileFunction` the unadvanced
  `fC->Child(id)` — the QUALIFIER node (the same defect
  § `qualifiedCtorLosesPortListAndBody27` already owns for constructors).
* `setFuncTaskQualifiers` unwraps a `Function_declaration` into its child ONLY in
  its very first `if` (`CompileStmt.cpp:1844`), which is reached only when the
  node handed in IS that `Function_declaration`. Behind a qualifier, the qualifier
  loop consumes the qualifier and returns the `Function_declaration` still
  wrapped, so `compileFunction`'s own `Child()` lands on the **`Lifetime_Automatic`
  node** instead of the `Function_body_declaration`.
* Everything derived from there is invalid: the NAME, the `Tf_port_list`, the body.
  `vpiVisibility` survives (its own `if` fired); `vpiAutomatic` does NOT (its `if`
  never saw the node). That is exactly the field-for-field shape of golden's
  object, which is how the reading was checked rather than assumed.

| cell | arm | golden |
|---|---|---|
| `local`+`automatic` (uvm's spelling) | `t64a` | `function ''`, nio=0, stmt unset, ret SET, method=1, vis=3, autom=0 |
| `local` alone / two-token alone / `automatic` alone | `t64a` controls | all correctly NAMED |
| `protected`+`automatic` | `t64b` | same artifact, **vis=2** |
| `virtual`+`automatic`, class-item `static`+`automatic` | `t64c` | same artifact, vis=1 |
| `virtual` alone, `static` alone, `automatic` alone | `t64c` controls | all correctly NAMED |
| a written **`static` LIFETIME** behind `local` | `t64c/c66c.sv` (golden-only: slang enforces the LRM and rejects it) | same artifact — so it is "a written lifetime", not the word `automatic` |
| the RETURN var | `t64c/c66c.sv` + every stub | a bare **`logic_var`** carrying only the CLASS's full name — no name, no typespec, no location. `VpiType` is compared, so our ordinary `int_var` would have kept the object unequal even with the name fixed. |

Reach, censused over BOTH corpora including every bundled UVM version (positive
control: the same pattern finds all 6 sites in `t64a`): **NINE sites** — uvm's
`uvm_reg_map.svh:464` and the `pp_output` copy `BuildUVMPkg` actually compiles
(`uvm_pkg.sv:75228`), plus **SEVEN** in `Ibex` (`SLANG_REJECT` both modes).
uhdm2rtlil has **none**. The byte verifier agrees: exactly `BuildUVMPkg` x 2
modes changed.

> **CORRECTED TWICE — RE-MEASURE, DO NOT INHERIT A NUMBER, not even from a
> verifier.** This paragraph first said "four sites ... plus two in Ibex". The
> pass-46 verifier corrected it to eight Ibex sites, "six in
> `ibex_icache_core_driver.sv`". **Both are wrong.** The master re-ran the
> census: `ibex_icache_core_driver.sv` has **five** (lines 22, 27, 154, 182,
> 189), `ibex_icache_mem_model.sv:47` and `ibex_icache_mem_monitor.sv:31` one
> each = **7 in the Ibex tree**, 9 in total. Immaterial to every gate — `Ibex`
> and `IbexGoogle` are `SLANG_REJECT` in both modes and their rows are
> unchanged — but it is the third consecutive pass whose reach figure was
> misstated, and a reach figure is what the NEXT pass ranks on.
>
> **The load-bearing half of the reach story, independently CONFIRMED:**
> `third_party/UVM/uvm-1.2/src` — what `SimpleUVM`, `SeqDriver` and `Scoreboard`
> compile — contains **ZERO** qualifier+lifetime sites. That, not the Ibex
> count, is why only `BuildUVMPkg` changes from law 2 even though four
> comparable tests compile a `uvm_pkg`.

**MEASURED, RECORDED, NOT IMPLEMENTED — the multi-method collapse.** When one
class holds SEVERAL such methods golden collapses them onto ONE object: `t64a`'s
six become one `function ''` at the LAST one's line but with the FIRST one's
KIND, and `t64b`'s `c65d` becomes one taking the LAST one's visibility — while
`t64b`'s `c65b` (a task first, then a function) does NOT collapse and yields three
objects, two of them not even methods. The behaviour is not uniform, no corpus
test has two in one class, so this emits one stub per declaration and leaves the
collapse to the arm's record instead of guessing. PROTOTYPES and OUT-OF-BODY
definitions are excluded for the same reason: different Surelog entry points, no
golden read.

## 3. A residue the arm found on the way (ranked below, do not lose it)

`t64a`/`t64c` also show golden stamping **`vpiAutomatic` on a plain class method
that writes `automatic`** (`f_auto_2tok`, `f_auto`: golden autom=1) where we stamp
nothing — our `VpiAutomatic` arm is guarded `&& !classScope`. Pre-existing at HEAD
(verified on the HEAD binary's own `t64a` database), NOT caused here, and NOT
fixed here: unlike the four sites above, a plain `function automatic` inside a
class is a common spelling, so it needs its own reach census and its own gate.

## 4. Gates — on this worktree's own binary, with the binary's md5 checked before and after every sweep

`SLANG_UHDM` pinned to this worktree's `build/slang-uhdm`
(`3e11fa1d0484ad08d8d8315cde9e457d`) for every run; `verify_golden.py:52` and
`tests/check_goldens.sh:5` both default to the MAIN-TREE binary and a false pass
is indistinguishable from a real one. **No build touched the tree while a sweep
was in flight** (pass 45 had to void a whole gate round for exactly that).

* goldens **23 PASS / 0 FAIL**, with a **NEGATIVE CONTROL on the gate script
  itself**: `SLANG_UHDM=/bin/false` gives **0 PASS / 23 FAIL**.
* u2r `testflags`: **0 diff lines** over 732 rows vs `results/gate_uhdm2rtlil.csv`.
* Surelog both modes: **0 diff lines** over 1589 rows vs
  `results/golden_surelog.csv`, whole row including `DUMP` — and the HEAD run in
  the same workdir is ALSO 0 diff lines, which is the baseline-validity check.
  Canaries by name: `InterfaceBinding` (the ranked-#1 regression control)
  `CMP_EQUAL` + `dump=match` in both modes, `BindHierPath` `CMP_EQUAL` + `match`,
  `LowMemPkg` / `InterfaceModExp` / `paramod_genscope_child` /
  `issue326_packed_mem` `match`, `FuncStruct` / `FuncStructVal` /
  `FuncIoTypespec` / `EvalFunc` / `ClassExtends` / `AssertDelayError` /
  `AssertTempError` `CMP_EQUAL`. `SLANG_REJECT` membership unchanged (286 in both
  runs, identical rows).
* **BYTE VERIFIER** (the whole-row CSV diff is blind inside the 27 already-
  `CMP_NOTEQUAL` rows), HEAD binary vs POST binary writing to the SAME workdir:
  **953 databases, 949 byte-identical, exactly 4 DIFFER — and all 4 are the
  targets**: `default/BuildUVMPkg`, `testflags/BuildUVMPkg`, `default/SimpleUVM`,
  `testflags/SimpleUVM`. `Scoreboard` did not flake in this run, so its reach
  statement needed no exclusion. The HEAD binary was rebuilt from a copy of this
  tree with the two touched files restored from `HEAD`, and it came out
  **md5-identical to the binary this pass built from pristine HEAD before writing
  any code** (`b9d8437fcff35e744d1e1c0926478d44`) — the baseline is the baseline.

## 5. Apparatus

New: `r10uvm46if.cpp` (interface_inst OBJECT + CONTAINER-POSITION census, `-p`
for pointer identity; refuses to report a zero population), `r10uvm46tf.cpp`
(task_func object census over the serializer; refuses likewise), `ifc.sh`,
`armif.sh`, `arms.sh` (all six `t63` cells, per-cell census diff AND cmp verdict,
FATAL rather than silence when an input is missing), `goldfile.sh` (golden for a
single FILE, needed for a golden-only cell), `clone45.sh` (prefix-anchored
re-namespacing, inheriting pass 44's lesson that a blanket sed renames the PROBE
BINARIES and every driver then reports perfection), arms `t63a`-`t63f`,
`t64a`-`t64c`.

**Apparatus defect found and fixed, reports-perfection family:**
`listdirect.sh` printed `LISTDIRECT=0` under four `census missing` lines when
handed a sweep WORKDIR instead of the `res.sh` TAG — a closed metric and a blind
one look identical. It now sets a flag and REFUSES to print the total
(`exit 3`), and its message names the right argument. Self-tested both ways.

## 6. Ranked for pass 47

1. **`BuildUVMPkg`/`Scoreboard`/`SeqDriver`/`SimpleUVM` all first-fail on
   `decompile:`** and every listing/io panel on them is now ZERO. That is the
   whole board's next question and nothing else on this list outranks it: dump the
   first unequal pair per test (uhdm-cmp `failLhs`/`failRhs`) and census the
   `VpiDecompile` residue as a POPULATION, the way `LSTOTAL` was built at pass 44.
2. **The `vpiAutomatic` class-method residue in §3** — smallest live item with a
   golden already in hand (`t64a`, `t64c`), needs a reach census over the corpora
   for plain `function automatic` inside a class plus its own gate.
3. `BINDWRONG` 757, unmoved for four passes: 342 owner-attribution and 82
   parameter-vs-folded-constant rows; `BINDTOTAL` 1681 = 938 extra / 743 miss.
   The extra half is the half to attack — it is the only one that cannot be a
   visibility artifact.
4. The `r10uvm42tw`/`r10uvm41ts` clone-sharing residue (3863/3827 per the panel),
   monotone in the CLONE-SHARING residue and legitimately able to worsen while the
   model improves — report it with that caveat.
5. `LISTDIRECT` 80 vs golden 56, `CPTOTAL` 580, `TSINSTTOTAL` 1074 (golden has 26
   class-instanced rows, so do NOT assume never-the-class), `CPCLASS` 25,
   `INITTOTAL` 52, `BODYOTHER` 434.
6. The PROGRAM arm of § 45 (still probe-blocked: `r10uvm44ls` has no `program`
   case) and the interface's file-scope import, both deliberately unimplemented.
7. The module arm of § `classKeyTsScopeOwner35`, newly readable since pass 45 and
   still 0 rows on the UVM-4 — check reach before ranking it up.
8. Carried, unchanged, with their measurements: the `types_t` ELEMENT position;
   the 238-row unspanned empty `array_typespec` family; the four `t60a` LISTED
   span rows; the module-implicit-net arm (a wash: clears 4 misses, mints 4
   BINDWRONG); BARE->SELF 438 rows homogeneous per routine; the socket-sharing
   residue; `t40a`; `t36b`; `t33d`; and the still-UNMEASURED halves — the ELEMENT
   half of pass 43's widened kind gate, and real/shortreal/union/class-handle in
   either position.

## 7. Code-audit findings from the pass-46 verifier — carried forward, none a mover

The verifier read both production hunks against their call sites and found no
defect any gate would catch. Four things it recorded that the NEXT pass should
know, because each is the kind of thing that later looks like a fresh bug:

1. **The `VpiFullName` rewrite cannot reach the def view.** `emitInstance` is
   entered from `UhdmExporter.cpp:3894` only for tops with `parentM == nullptr`,
   and the rewrite/record is guarded on `parentM && parentM->VpiFullName().length()`.
   That guard is also what keeps `InterfaceBinding` and u2r's `add_sub_bind_if`
   byte-inert — the two regression controls — so do not "simplify" it away.
2. **`bindIfaceTwinSrc` entries are never erased** when they are recorded against
   a holder that never reaches the `Interfaces` install site (the gen-scope and
   interface holders this pass deliberately excluded). Benign process-lifetime
   retention of a vector of pointers, no output effect.
3. **Law 2 leaves two `io_decl` objects unattached**, and slang-uhdm never calls
   `Serializer::GarbageCollect`, so they ARE serialized into `BuildUVMPkg`'s
   database. Both `uhdm-cmp` and `uhdm-dump` traverse from the design root, so
   neither can see them — the cmp verdict and the DUMP column are both unchanged
   — and this is the identical pattern § `qualifiedCtorLosesPortListAndBody27`
   already established. Worth knowing before someone "discovers" it.
4. Cosmetic: `plainModuleTargetBind` returns a pointer used only as a predicate
   (`(void)bsyn9;` at the call site) and could be a `bool`. Left alone under the
   campaign's no-premature-refactor rule.

The verifier also settled the `Scoreboard` byte flake INSIDE this pass rather
than accepting a blanket exclusion, which is the right precedent: with the HEAD
binary ALONE, two consecutive rounds in one workdir gave `ebe12c0a` then
`e6b9b552`, and the POST binary produced BOTH of those same two values across
runs, while `SeqDriver` stayed byte-identical (`768c8875`) on both binaries. So
the 5-database byte delta is the 4 real targets plus a database that is
nondeterministic with a FIXED binary. Do this rather than filtering `Scoreboard`
out by name.
