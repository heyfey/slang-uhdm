# r11u70 — a typed pattern cast is `vpiCastOp` over `vpiConcatOp`, and its member keys leak wires

Base `3e392403` (v1.87 pass 67).  Pins per `SUPPORT_MATRIX.md`: slang
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 (`0445655ee7`), uhdm2rtlil v0.68.
Every golden in this directory is a real Surelog v1.87 run (`arm.sh`), never a
carried-forward framing.

Target: TRIAGE2's **C5 cast arm**
([tools/probe/r11u44repro/TRIAGE2.md:451](tools/probe/r11u44repro/TRIAGE2.md#L451)),
written down as a residue twice and held back twice —
[tools/probe/r11u34repro/README.md:384](tools/probe/r11u34repro/README.md#L384)
R2 and [tools/probe/r11u49repro/README.md:382](tools/probe/r11u49repro/README.md#L382)
R2, both warning that it is "a shape change plus a phantom-net mint, not a
stamp".  **Both halves land here, and the row CONVERTS.**

---

## 0. THE HEAD AND THE WHOLE RESIDUE, RE-MEASURED AT `3e392403`

Pristine binary `md5 575be751afd6818113a6788148e78797`, byte-identical to the
main tree's `build/slang-uhdm` at the base.  Two rows, one test, two modes;
each `uhdm-cmp` run reports **one** head (`grep -c '^LHS:'` = 1 on both).
Full logs: `evidence/head.pris.typed_named_pattern.*.cmp`, both files
`md5 7121b2aa39b8e710486fc3a39dbfe718` — the two modes are the same text.

```
LHS:
decompile:
ref_typespec: (work@typed_named_pattern), id:103
|vpiParent:
\_operation: , id:102, line:22:35, endln:22:132
|vpiFullName:work@typed_named_pattern
|vpiActual:
\_struct_typespec: (q::op32_i_t), id:13, line:9:11, endln:15:4
RHS: <null>
```

The singular overload hides the owner, so the owner was read out of **golden's
own dump**: operation `id:102` at `22:35` is the `vpiOpType:67` (`vpiCastOp`)
that is the `vpiRhs` of

```systemverilog
localparam op32_i_t NOP_CAST = op32_i_t'{imm_11_0: 12'h123, rs1: 5'd5,
                                         funct3: 3'd2, rd: 5'd9,
                                         opcode: '{opc: 1'b1, c11: 2'b11}};
```

**THE WHOLE RESIDUE, not just the head.**  Order-blind whole-dump distance at
the base is **677 lines** in each mode (ids and workdir paths normalised).
Sectioned, that is:

| section | golden-only | ours-only | what it is |
|---|---:|---:|---|
| `uhdmallModules`, minus the `NOP_CAST` assign | 35 | 0 | the FIVE leaked wires, 7 lines each |
| `uhdmallModules` / `NOP_CAST` | 37 | 40 | the cast shape, def listing |
| `uhdmtopModules` / `NOP_CAST` | 58 | 7 | the cast shape, elab listing |
| `uhdmtopModules`, minus that assign | 0 | 0 | — |
| `uhdmallPackages`, `uhdmtopPackages` ex-naming | 0 | 0 | — |
| `uhdmtopPackages` naming | 12 | 10 | `vpiFullName` and `vpiParent` only |
| `uhdmallClasses` | 0 | 0 | — |
| `weaklyReferenced` | 335 | 29 | unreachable to the judge |

so **PREDICTION, stated loudly before a line was written: CONVERT, not
ADVANCE** — the only judged content that differs is this law's, because the
`uhdmtopPackages` block differs only in `VpiFullName` (`work@typed_named_pattern.q::op32_i_t.imm_11_0`
vs `q::op32_i_t.imm_11_0`) and a `vpiParent` back-link, and no generated
`Compare` reads either.  **Measured after: `typed_named_pattern` is
`CMP_EQUAL` in BOTH uhdm2rtlil modes.**

---

## 1. THE PRODUCER

Surelog has **no assignment-pattern node for a CAST'd pattern**.  The law
`castDefaultPatternConcat` (r10sing4) already says so for one face —
`src/ExprEmit.cpp`'s `StructuredAssignmentPattern` arm carries its decoding —
and scoped itself to "DEFAULT-only keys over a PREDEFINED-INTEGER cast target",
leaving "named/positional keys and typedef/struct cast targets" on the old
`vpiAssignmentPatternOp` road because "they need the full cast-typespec
machinery".  This pass builds that machinery for the named-key struct face.

`T'{m: v, ...}` compiles to

```
operation vpiOpType:67 (vpiCastOp)          span = the whole `T'{...}`
  vpiTypespec -> ref_typespec (<scope>) -> T's own typespec object
  vpiOperand:
    operation vpiOpType:33 (vpiConcatOp)    span = the pattern minus its `'`
      vpiOperand: ref_obj  <key name>       one per key, in SOURCE order,
      vpiOperand: <value>                   then the value
      ...
```

and the key `ref_obj` is an **ordinary written name**: it carries no
`vpiStructMember` (that flag belongs to the `default` key of the landed int
arm), and it BINDS the way any name written in a module binds —
`UhdmWriter::lateBinding` searches the module's nets and variables and, finding
none, **mints an implicit wire** (`UhdmWriter.cpp:3985`, `vpiNetType` 1).  That
is the "phantom net": not a decoration on the operation but a real module net,
listed in the DEFINITION listing's `vpiNet` vector after every declaration —
and `instance::Compare` compares `Nets()` as a VECTOR, so the list and its
order are judged.

The cast never folds.  `reduceExpr` walks the concat's operands and stops dead
on a `ref_obj`, so the elaborated listing carries the SAME tree as the
definition one; only the positional form (no `ref_obj` at all) reaches a fold.
That is why this law needs no view split: the two listings are one tree.

---

## 2. THE GOLDEN GRID — 15 arms, target kinds x key forms x holders x views

`arm.sh <file> <outdir> <binary>` runs one arm through Surelog and one
slang-uhdm binary and dumps both; `shape70.py` is the SHAPE LISTER (every
`param_assign` and `cont_assign` in every top-level listing, rendered
recursively and ENCODING+SIZE aware, plus each module's net list IN ORDER);
`score70.sh` joins golden / pristine / law per cell.  Full golden text in
`evidence/GRID.golden.txt`, the three-way score in `evidence/GRID.score.txt`.

| arm | what it varies | GOLDEN |
|---|---|---|
| `c1` | the corpus shape, packed struct, named keys, module localparam | op67/op33, 5 wires minted, BOTH listings, no fold |
| `c2` | **POSITIONAL** keys, packed struct | op67/op33 with **values only — no `ref_obj`, no mint**, and the ELAB listing **FOLDS** the concat to one 8-bit constant |
| `c3` | **UNPACKED** struct, named keys | op67/op33 + 2 wires, both listings |
| `c4` | packed **UNION**, named keys | op67/op33 + 2 wires (`union_typespec` target) |
| `c5` | unpacked **ARRAY** typedef, positional | op67/op33, no mint, ELAB folds |
| `c6` | vector typedef, **`default`** key | op67/op33 with a `ref_obj` named `default` carrying **NO actual**, no mint |
| `c7` | the param declared in the **PACKAGE**, read from a module | op67/op33 and the wires ARE minted in the module's def net list, but the module copies' key refs are **DANGLING**; only the package ELAB copy binds |
| `c8` | the cast in an **`initial` statement** | wires minted in the def listing (`o,v,a,b`) |
| `c9` | the cast as a **cont_assign Rhs** | op67/op33 + wires, both listings |
| `c10` | keys that NAME an existing `wire`/`logic` | binds the declarations, **mints nothing** |
| `c11` | **two** cast params, same key names | **ONE** pair of wires, shared |
| `c12` | `default` key over a **struct** target | `ref_obj default`, no actual, no mint |
| `c13` | the **UNCAST twin** `'{a: 1, b: 2}` | op75 — tagged in def, typed+flat in elab.  Unchanged. |
| `c14` | a **computed** key value `I[3:0]` | op67/op33 in both, and the ELAB listing **REDUCES** the value to `4'b0100` |
| `c15` | the cast as a **child-instance parameter override** | the child's ELAB param is op67/op33 scoped to the instance path |

Neighbour fences that must not move, and did not: `c13` (the uncast twin, which
is also the corpus test's own `NOP_PLAIN` sibling), and `DefaultPatternAssign`
in the Surelog suite — the landed `int'{default: 1}` arm, `CMP_EQUAL` before
and after.

`c4` is **G-ONLY**: slang rejects a packed-union assignment pattern
("not all elements of array are covered by an assignment pattern key"), so that
arm teaches error-recovery, not golden, and its union branch is recorded from
the golden side alone.

---

## 3. THE LAW, AND EVERY ARM IT IS FENCED ON

**ONE admission test, read by both halves** —
`UhdmExporter::castNamedStructPattern70` (`src/ExprEmit.cpp`).  The parameter
road consults it, turns its own struct flatten off and records the expression;
the expression emitter builds the cast shape for exactly the recorded ones.  A
pointer-identity set, cleared per `emitParameters` call, so no other holder can
pick the shape up.  Everything the grid fenced out is fenced there, once:

* the **CAST spelling** only (`c13`).
* **member keys** only — `default` (`c6`, `c12`) and positional (`c2`, `c5`)
  are two further shapes, neither of them this one.
* a **struct or union** cast target (`c5`, `c6`).
* no key that **names one of the holder's own declarations** (`c10`).
* **literal** key values throughout, nested patterns included (`c14`).
* the parameter is the **holder's own declaration**, `ps.getParentScope() == &body`
  — a materialized package copy keeps the shape but dangles its key refs
  (`c7`), a third binding rule this law does not own.

**Three separate mechanisms, each behind its own arm:**

1. **the SHAPE** — `src/ExprEmit.cpp`'s `StructuredAssignmentPattern` case
   grows a second arm beside `castDefaultPatternConcat`'s int arm, building
   op67-over-op33 with the target's `ref_typespec` and the alternating
   key/value operands.  Constants stay UNparented, every other operand keeps
   its parent, exactly as the int arm measured.
2. **the ROAD** — `src/ParamEmit.cpp` clears `structPat` for an admitted
   pattern, so the ELABORATED listing stops rebuilding a flat op75 the
   definition listing no longer has.  It is not a widening of `structPat`: an
   UNPACKED struct never set that flag at all (`c3`), which is why the
   admission REPLACES the road rather than riding it.
3. **the MINT** — the key `ref_obj`s bind a freshly minted `logic_net`
   (`vpiNetType` 1, named `<scope>.<key>`), one per (instance, key name) so two
   patterns share a wire (`c11`).  Parameter initialisers are emitted BEFORE
   their module's nets, so the def-view mint is PARKED per module in
   `ExprEmit` and DRAINED in `src/ModuleEmit.cpp` right after the
   declarations — golden's order, `o_cast, o_plain, imm_11_0, rs1, funct3, rd,
   opcode`.  The ELABORATED listing mints its own copies and lists none, which
   is what golden's elab module shows.

`R11U70_CASTDBG=1` prints one line per parameter the admission test looks at
and one per pattern the shape arm reaches.  The `home=0` reading is what
located the emission-order fact above.

**GRID SCORE: TO 13, AWAY 0, MOVED 0, STILL 33, SAME 55, G-ONLY 1.**

---

## 4. CENSUS — both corpora, both modes, movers named a priori

**The population is a SOURCE fact.**  A database cannot tell `T'{m: v}` from
`'{m: v}`; that is the whole of the head.  So the census instrument
(`census70.py`, `evidence/CENSUS.source.txt`) is a comment-, string- and
block-comment-stripping scanner over every file either corpus can hand a
compiler.  25 raw hits; 14 are `tagged <member> '{...}` union patterns and 6
are `return '{...}` — preceding-token false positives, printed rather than
filtered so a reader can check them.

**The five genuine cast sites, both corpora:**

| corpus | test | site | keys | holder | status at base |
|---|---|---|---|---|---|
| uhdm2rtlil | `typed_named_pattern` | `dut.sv:22` | named | param | **CMP_NOTEQUAL x2 — the law's cell** |
| uhdm2rtlil | `rp32_r5p_hamster` | `rp32/hamster/r5p_hamster.sv:309` | named | param | SLANG_REJECT x2 — no database on our side |
| surelog | `CastStructMember` | `dut.sv:7` | positional | param | SLANG_REJECT x2, and positional is fenced |
| surelog | `DefaultPatternAssign` | `dut.sv:2` | `default` | param | CMP_EQUAL x2 — the landed int arm, fenced |
| surelog | `Verilator` | `t_struct_init.v:45` | named | a `const` VARIABLE | SLANG_REJECT x2, and the holder is out of scope |

**PREDICTED MOVER SET, stated before scoring: `typed_named_pattern` in both
uhdm2rtlil modes, and NOTHING ELSE — zero movers in the Surelog suite, both
modes** (`evidence/PREDICTION.txt`).

**POSITIVE CONTROL, on the database side, corpus-wide.**  `dbcensus70.sh` runs
the shape lister over every database in a `verify_golden.py` workdir and counts
the two columns this law moves.  Over the 804 uhdm2rtlil/default databases:

```
pristine  OP67 cells 18   OP75 cells 831
law       OP67 cells 20   OP75 cells 829
```

Both columns are large on both sides, so a zero elsewhere is a fact about the
corpus and not about the instrument; and the whole difference is two cells, in
one file — `typed_named_pattern`'s def and elab listings
(`evidence/DBCENSUS.*.txt`).

**MEASURED AFTER.**  `byteverify.sh SELFCHECK=1` reports **MOVERS 2 / 1608** on
uhdm2rtlil, the two `typed_named_pattern` databases, the prediction name for
name with nothing outside it; and **5 / 960** on the Surelog suite, every one a
UVM-family COIN proven by RE-DRAW from the UNCHANGED binaries — including
`SimpleUVM/default`, whose SECOND **law** draw lands on the pristine hash, and
whose order-blind distance is the documented 4-line `UINT`/`vpiDecompile`
line-number class on 1113011 identical lines.  Full table in
`evidence/GATES.txt`.

---

## 5. GATES — all green

See `evidence/GATES.txt` for the full text: binaries frozen and every
`cmds.txt` audited by path; goldens 23/0 with the `/bin/false` negative control
0/23; both corpora both modes row-joined against the committed baselines with
only the law's own rows differing, each quoted; byteverify with SELFCHECK
against this pass's own pristine workdirs; the canary battery
(`canaries.sh` + `ctcan2.sh` + `canaudit.sh`, audited=29 UNCOVERED=0
FENCE-BREACH=0) and every protected database md5 at the hash the brief names.

**THE CONVERSION, said loudly.**  The committed baseline row

```
typed_named_pattern,default,CMP_NOTEQUAL,decompile:,,
typed_named_pattern,testflags,CMP_NOTEQUAL,decompile:,,
```

becomes

```
typed_named_pattern,default,CMP_EQUAL,,,differ
typed_named_pattern,testflags,CMP_EQUAL,,,differ
```

`results/*.csv` is READ-ONLY and was **not edited**; the integrator promotes
the row.  Scoreboard after the landing: uhdm2rtlil **788 / 16 / 67** in each
mode, Surelog suite 474/9 + 469/8 — unmoved.

---

## 6. RESIDUES

* **R0 — the UNPACKED cast face's ELABORATED listing.**  Grid `c3`'s
  `uhdmallModules` cell converts and its `uhdmtopModules` cell does not: the
  unpacked elab road is `unpElabFlat61`'s, which never consults `structPat`, so
  it rebuilds the flat op75 there.  Golden wants the same op67/op33 tree it
  writes in the def listing.  One arm, no corpus cell (the census finds no
  unpacked-struct cast in either corpus).  **This is the R0 the next pass
  should take if it wants this family.**
* **R1 — the POSITIONAL cast face, and its FOLD.**  Grid `c2`/`c5`: golden
  writes op67 over a concat of bare VALUES with no `ref_obj` and no mint, and
  then the elaborated listing folds the whole concat to one constant at the
  target's width (`p2_t'{4'd1, 4'd2}` -> `8'b00010010`).  Two mechanisms, not
  one.  Corpus population: `CastStructMember`, SLANG_REJECT both modes.
* **R2 — the `default` key over a NON-INTEGER cast target.**  Grid `c6`/`c12`:
  golden writes op67 over a concat whose first operand is a `ref_obj` named
  `default` with **no actual at all** and no mint — the landed int arm's shape
  minus the fold, which only `int` gets.  No corpus cell.
* **R3 — the MATERIALIZED package copy's DANGLING key refs.**  Grid `c7`: a
  package-declared cast param keeps the op67/op33 shape in every listing and
  the wires ARE minted in the importing module's def net list, but only the
  PACKAGE's elaborated copy binds its key refs; the package def copy and both
  module copies leave `vpiActual` unset.  Fenced out here by
  `ps.getParentScope() == &body`.  No corpus cell.
* **R4 — the computed key value's elaborated REDUCTION.**  Grid `c14`: golden
  reduces a value operand (`I[3:0]` -> `4'b0100`) in the elaborated listing
  while leaving the shape and the key refs alone; we would carry the
  `part_select` through.  Fenced out here by the literal-value test.  No corpus
  cell.
* **R5 — the non-parameter holders.**  Grid `c8` (an `initial` statement) and
  `c9` (a cont_assign Rhs) both mint wires in golden's def listing and both
  carry the cast shape; the law is scoped to parameter initialisers because
  that is where its binding home is opened.  `Verilator`'s `t_struct_init.v:45`
  `const b4_t` variable is the corpus face, SLANG_REJECT both modes.

## 7. FILES

| file | what it is |
|---|---|
| `arm.sh` | one arm through Surelog + one slang-uhdm binary, both dumped, rc recorded (from r11u34 via r11u49) |
| `shape70.py` | THE SHAPE LISTER — every param/cont assign in every listing, rendered recursively with constant sizes and encodings, plus each module's net list IN ORDER |
| `score70.sh` | joins golden / pristine / law per cell: SAME / TO / AWAY / STILL / MOVED / G-ONLY |
| `census70.py` | THE CENSUS — a comment-stripping source scanner for the cast spelling, both corpora |
| `dbcensus70.sh` | the database-side positive control: op67 and op75 param cells over a whole workdir |
| `c1.sv` … `c15.sv` | the 15 golden grid arms of §2 |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the standing battery (r10uvm221 generation) |
| `evidence/` | the heads, the golden grid, the three-way score, the census, the prediction, the database census and the gates |
