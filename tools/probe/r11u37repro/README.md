# r11u37 — § typeParamNameMintsDefNet37

**The phantom def-view net a `type` parameter's expression NAME mints.**
The r11u29 triage's K12: golden's module DEFINITION carries a `logic_net` that
the module never declares, minted from a name written inside a type-parameter's
data type. This is a golden-ONLY object we have to MINT — the reverse of the
usual decline laws.

Base `34b04279`, worktree `/tmp/wt_r11u37`, patch `/tmp/r11u37.patch`.
Production surface: `src/ModuleEmit.cpp`, `src/UhdmExporter.cpp`,
`include/UhdmExporter.h`. `results/*.csv` was READ ONLY.

---

## 1. The two heads, re-measured at 34b04279

Pristine build from this worktree, `-j 2`, md5
`c8d72796d4550874084656de68f7b845` — **byte-identical to the main tree's
`build/slang-uhdm` at 34b04279**, so the baseline is the pin, not a copy.
Frozen `chmod 555` at `/tmp/r11u37_pris.bin`; all four `cmds.txt` in the
targeted sweep name that path and no other.

| row | cmp lines | heads | cmp rc |
|---|---|---|---|
| `param_type_logic_width` default | 390 | 1 | 255 |
| `param_type_logic_width` testflags | 390 | 1 | 255 |
| `packed_struct_array_fifo` default | 6446 | 1 | 255 |
| `packed_struct_array_fifo` testflags | 6446 | 1 | 255 |

`param_type_logic_width`'s head (LHS is golden), quoted:

```
LHS:
module_inst: work@shift_reg (work@shift_reg), id:285, line:4:1, endln:9:10
|vpiNet:
\_logic_net: (work@shift_reg.d_i), id:290, line:5:18, endln:5:21
|vpiNet:
\_logic_net: (work@shift_reg.d_o), id:292, line:6:18, endln:6:21
|vpiNet:
\_logic_net: (work@shift_reg.b),   id:294, line:17:48, endln:17:49
  |vpiNetType:1
```

Three nets on the golden side, two on ours — a `module_inst::Nets` VECTOR size
mismatch, so both containers print (RESUME.md §9). Line 17 column 48 is the
`b` inside `$bits(b)` in `shift_reg #(.dtype(logic [$bits(a) + $bits(b) -
1:0])) u (` — a name of the INSTANTIATING module, minted into the
INSTANTIATED module's definition. `a`, at column 37 of the same line, gets no
net.

`packed_struct_array_fifo`'s head is the same shape on its own definition:
golden carries `logic_net (work@packed_struct_array_fifo.d_t)` at `8:28`,
the NAME of the typedef used as the default of `parameter type dtype = d_t`.

The rest of `param_type_logic_width`'s whole-dump diff (97 lines, paths and
ids normalised) is judge-invisible: `vpiFullName` text
(`work@param_type_logic_width.a` vs `work@tb.t.a`; no generated `Compare`
reads VpiFullName) and unreferenced top-level `logic_typespec`s. **The phantom
net is its ONLY judge-visible difference** — which is why it is the conversion
candidate and the fifo, with two extra `packed_array_typespec`s and a
differently-scoped `ref_obj`, is not.

---

## 2. The producer, decoded

`UhdmWriter::lateBinding` (Surelog `src/DesignCompile/UhdmWriter.cpp:3297`)
walks `mod->getLateBinding()` while WRITING a definition. A `ref_obj` reaches
that list when `CompileHelper::bindVariable` (`src/DesignCompile/CompileStmt.cpp:3095`)
cannot walk the reference's `pexpr` parent chain up to a scope holding the
name (`CompileExpression.cpp:1837/2859/3015/5801/5825`). Having found no
package member, no typedef, no enum constant, no variable and no value for the
name, the mint arm at **`UhdmWriter.cpp:3982-4007`** runs:

```cpp
logic_net* net = s.MakeLogic_net();
net->VpiName(name);
net->VpiParent(m);
net->VpiLineNo(ref->VpiLineNo());  ... VpiEndColumnNo(ref->VpiEndColumnNo());
net->VpiNetType(UhdmWriter::getVpiNetType(elem->m_defaultNetType));
ref->Actual_group(net);
nets->push_back(net);            // AFTER every declared net
```

so: a bare `logic_net`, `vpiNetType 1`, **no typespec**, the REFERENCE's own
span, appended last. The `::` arm at `:3303` `continue`s, which is why a
package-qualified name never mints. `writeModule` calls `lateBinding` at
`:1575/:1623`; `writeInterface` does not (the elaborated-instance writer at
`:4834` does instead); the class call at `:1067` is commented out.

Two syntax keys reach it from a `type` parameter.

### Key 1 — the DEFAULT that is a bare type NAME

`parameter type dtype = d_t` mints `logic_net(<mod>.d_t)` at the NAME's span,
in the module that DECLARES the parameter. The gate is **visibility from the
module itself** — exactly the `$unit` rule `mintUnitEnumNets` already models,
because `lateBinding` searches the COMPONENT and never the compilation unit.

### Key 2 — the ranged OVERRIDE ACTUAL at an instantiation

`child #(.dtype(logic [$bits(a) + $bits(b) - 1:0]))` mints in the **CHILD's**
definition: the data type is compiled against the child's component, so the
child's late-binding list is the one that receives the reference. WHICH names
mint is decided by whether `bindVariable`'s `pexpr` chain still reaches the
instantiating module. The range bound's **leftmost-operand chain** keeps it and
everything else loses it: descend through parentheses and the LEFT operand of
binary operations only; the chain ends at a bare identifier or at
`$bits(<bare identifier>)`, and THAT one leaf binds while every other
identifier in the bound mints. Each range bound restarts its own chain.

A VALUE parameter override with the identical expression mints nothing at all
— this is the DATA-TYPE compile, not the parameter compile.

---

## 3. The GOLDEN GRID — `goldengrid.sh`, 48 arms

Golden-only; nothing here builds or runs slang-uhdm. `evidence/goldengrid.txt`
carries every arm's **rc, top-level holder count and full net list**, so an arm
whose compile reached nothing can never read as "golden mints nothing here".
Controls: arm `ab` MUST mint `work@c_ab.b` (positive), arm `zz` names a
non-existent source and MUST read `rc=1 holders=0 ARM COMPILED NOTHING`
(negative). Both pass; `compiled-nothing = 1`, exactly the `zz` control.

### A — which names mint from a ranged override (27 arms, all `rc=0`)

`a` is `[7:0]` and `b` is `[W-1:0]`, both declared in the instantiating module.

| arm | override actual | golden mints in the CHILD def |
|---|---|---|
| `ab` | `logic [$bits(a) + $bits(b) - 1:0]` | **b** @5:41 |
| `ba` | `logic [$bits(b) + $bits(a) - 1:0]` | **a** @5:41 |
| `aa` | `logic [$bits(a) + $bits(a) - 1:0]` | **a** @5:41 (the SECOND one) |
| `aonly` | `logic [$bits(a) - 1:0]` | — |
| `bonly` | `logic [$bits(b) - 1:0]` | — |
| `p1` | `logic [1 + $bits(a) - 1:0]` | **a** @5:34 |
| `p2` | `logic [a + b - 1:0]` | **b** @5:28 |
| `p3` | `logic [$bits(a) + $bits(b) + $bits(a) - 1:0]` | **b** @5:41, **a** @5:52 |
| `p4` | `logic [$bits(a) * $bits(b) - 1:0]` | **b** @5:41 |
| `p5` | `logic [$bits(b):0]` | — (no operation at all) |
| `p6` | `logic [$bits(a) + $bits(b):0]` | **b** @5:41 |
| `s1` | `logic [$bits(a) + ($bits(b) * 2) - 1:0]` | **b** @5:42 |
| `s2` | `logic [($bits(a) + 1) + $bits(b) - 1:0]` | **b** @5:47 |
| `s3` | `logic [$bits(a) + $bits(b[0]) - 1:0]` | — (INDEXED name: `compileSelectExpression`) |
| `s4` | `logic [-$bits(a) + 16 - 1:0]` | **a** @5:31 (chain dies at the unary op) |
| `s5` | `logic [8 + W - 1:0]` | — (a PARAMETER reduces before a ref exists) |
| `s6` | `logic [$bits(a) + $bits(a) + $bits(b) - 1:0]` | **a** @5:41, **b** @5:52 |
| `t1` | `logic [$bits({a, b}) - 1:0]` | **a** @5:31, **b** @5:34 (chain dies at the concat) |
| `t2` | `logic [$bits({a, b, a}) - 1:0]` | **a**, **b** |
| `t3` | `logic [(-$bits(a)) - 1:0]` | **a** @5:32 |
| `t4` | `logic [$bits(a) + (-$bits(b)) - 1:0]` | **b** @5:43 |
| `t5` | `logic [(1==1) ? $bits(a) : $bits(b):0]` | — (the conditional reduces) |
| `t6` | `logic [$bits(a) - 1:$bits(b) - $bits(b)]` | **b** once @5:54 (right bound, own chain) |
| `w1` | `logic [$bits(zq) - 1:0]` | **zq** @5:30 — exempt leaf, but UNRESOLVABLE |
| `w2` | `logic [W + $bits(a) - 1:0]` | **a** @5:34 |
| `w3` | `logic [a - 1:0]` | — |
| `w4` | `logic [$bits(a) + $bits(zq) - 1:0]` | **zq** @5:41 |

### B — the bare type NAME as a default (13 arms, all `rc=0`)

| arm | shape | golden |
|---|---|---|
| `q3` | `parameter type dtype = d_t`, `d_t` a `$unit` typedef in the same file | `work@c_q3.d_t` @2:38 |
| `u1` | same, module also declares `zz1`,`zz2` | `d_t` **LAST**: `d_i,d_o,zz1,zz2,d_t`; the ELAB child carries `d_i,d_o` only |
| `u2` | `= p::d_t` (package-QUALIFIED) | — |
| `u3` | `localparam type dt2 = l_t`, `l_t` a module-LOCAL typedef | — |
| `v1` | `= e_t`, a `$unit` typedef from ANOTHER file | `work@c_v1.e_t` @1:38 |
| `v2` | `= d_t` AND the module declares `logic d_t;` | the DECLARED net only (@3:9), no phantom |
| `v3` | BODY `localparam type dt2 = d_t` | `work@c_v3.d_t` @3:25 |
| `v5` | `= d_t`, module NEVER instantiated | `work@c_v5.d_t` @2:38 |
| `y2` | two `type` params both `= d_t` | ONE net, at the FIRST default's span @2:35 |
| `x1` | `= k_t` with `import pk::*;` INSIDE the module | — |
| `x2` | `= k2_t` with `import pk2::*;` at `$unit` scope | `work@c_x2.k2_t` @3:38 |
| `r3` | OVERRIDE `.dtype(d_t)` (a bare name, not a range) | in the **PARENT**: `work@m_r3.d_t` @5:37 |
| `y1` | `logic [$bits(a) + $bits(d_t) - 1:0]` | — (`$bits(<type name>)` makes no ref) |

### C — controls (8 arms, all `rc=0`)

| arm | shape | golden |
|---|---|---|
| `q1` | VALUE parameter override `.P($bits(a) + $bits(b))` | — nothing, anywhere |
| `q2` | the ranged override, but the CHILD declares `logic [1:0] b;` | the child's OWN `b` @2:15, no phantom |
| `r1` | a PLAIN net decl `logic [$bits(aa)+$bits(bb)-1:0] w;` | **aa**, **bb** — the same habit off the parameter path |
| `r2` | a RANGED type-param DEFAULT, both names unresolvable | **aa**, **bb** |
| `u4` | INTERFACE holder, `= d_t` | the ELABORATED instance `work@tb_u4.ii.d_t`, NOT the def |
| `v4` | PROGRAM holder, `= d_t` | — |
| `y3` | CLASS holder, `= d_t` | — |
| `zz` | (negative control) | `rc=1 holders=0 ARM COMPILED NOTHING` |

---

## 4. The law as shipped (gated)

`§ typeParamNameMintsDefNet37`, `src/ModuleEmit.cpp`
(`collectTypeParamLateBindNets37` / `mintTypeParamLateBindNets37`), called from
`src/UhdmExporter.cpp` at the END of the definition write phase — the slot
where `writeModule` calls `lateBinding`. The index is built design-wide first,
because a name written in a PARENT's instantiation mints in the CHILD's def.

**Holder gate.** MODULE definitions only, DEF VIEW only. Interfaces (`u4`),
programs (`v4`) and classes (`y3`) are MEASURED and deliberately NOT modelled:
no corpus row witnesses them and the interface face belongs to a different
pass. Blackboxed defs are skipped.

**Key 1 gate.** The default's type must be a `NamedTypeSyntax` whose name is a
plain `IdentifierNameSyntax` (so `p::t` is out, `u2`). The name must NOT be
visible from the module itself: not declared in the body or its header
(`u3`, and a same-header TYPE PARAMETER), not brought in by an import the
MODULE carries (`x1` in, `x2` out), and not the name of a net/variable the
module declares (`v2`). One net per NAME, first span wins (`y2`).

**Key 2 gate.** A `NamedParamAssignment`/`OrderedParamAssignment` whose expr is
an `IntegerTypeSyntax` with a `SimpleRangeSelect` dimension. Per bound, the
leftmost-operand chain leaf is computed and EXEMPTED; every other
`IdentifierName` in the bound mints, provided it resolves in the INSTANTIATING
body to a `Net`/`Variable`/`Port` (a parameter folds — `s5`; a type name folds
— `y1`) and the CHILD does not declare it (`q2`). `ElementSelect`,
`ScopedName` and `MemberAccess` subtrees are not descended (`s3`).

**Not shipped, measured.** An identifier that resolves NOWHERE mints too, even
from the exempt leaf (`w1`, `w4`, `r2`), and the same habit fires off a plain
net-declaration range (`r1`). No corpus row carries an unresolvable name in a
type-parameter data type, so the shipped Key-2 gate is the narrow one. This is
recorded, not guessed: the three arms are in the committed grid.

**Landed type-param laws respected.** Passes 17/18/20/30/31/34 touch
parameters, ranges and typespecs; this law adds ONLY `logic_net` objects to a
definition's `Nets` vector and reads no typespec. Their witnesses stay — the
row gate below moves one row and no other.

---

## 5. Census, prediction, controls — `census.sh`

Run BEFORE the sweeps. It lists every site of both syntax keys in both corpora
with a per-site verdict (the SHAPE LISTER), so the zeros are readable, and
carries its own positive control (the two corpus witnesses must appear in the
FIRE lists). `evidence/census.txt`.

**PREDICTED MOVER SET, by name, a priori:**

* `uhdm2rtlil` `param_type_logic_width` × {default, testflags} — **CONVERSION**
* `uhdm2rtlil` `packed_struct_array_fifo` × {default, testflags} — ADVANCE ONLY
* `surelog` — **NONE**

Everything else gated, with the reason: `type_param_packed_dim` and
`type_param_unpacked_port` default to a SAME-HEADER type parameter;
`type_param_override_elem_sel` and `TypeParameterAsPortTypeWithLogicAnonymous`
override with `logic [1:0]` (no identifier); every `.TagType/.AuxType/.DATA_T/.T`
site in the ariane family ranges over PARAMETERS only, and every ariane-family
row is `SURELOG_FAIL`/`SLANG_REJECT`/`NO_DATABASE` anyway;
`ClassTypeParamAlias`, `class_test_53` and `riscv_instr_pkg` are CLASS holders;
`cva6_equiv` carries no `dut.sv`/`project.f` and is not a discovered test.

---

## 6. Gates — all green

Two frozen binaries, both audited by PATH in every `cmds.txt`:
pristine `/tmp/r11u37_pris.bin` md5 `c8d72796d4550874084656de68f7b845`
(= the main tree's at 34b04279), law `/tmp/r11u37_law.bin` md5
`4c10c4bae1347ce2e1e0916d64596866`. Four independent full sweeps
(`--jobs 2`, my own `--out`/`--workdir`, `SLANG_UHDM` exported).

**(1) Build + md5** — pristine byte-identical to the main tree; law builds
clean at `-j 2`.

**(2) Goldens** — `23 PASS / 0 FAIL`; negative control `SLANG_UHDM=/bin/false`
→ `0 PASS / 23 FAIL`.

**(3) uhdm2rtlil row gate** (`evidence/ct8rows_u2r.txt`). My pristine sweep
reproduces the committed baselines **byte-identically, both modes** (`PASS:
every row byte-identical to the committed baseline`). The law moves exactly
ONE row per mode, and it is the law-named conversion:

```
< param_type_logic_width,default,CMP_NOTEQUAL,decompile:,,
> param_type_logic_width,default,CMP_EQUAL,,,differ
< param_type_logic_width,testflags,CMP_NOTEQUAL,decompile:,,
> param_type_logic_width,testflags,CMP_EQUAL,,,differ
```

Scoreboard: **774 / 30 → 775 / 29 in BOTH modes.**

**(4) Surelog row gate** (`evidence/ct8rows_surelog.txt`). Status histograms
unchanged in both modes — `474 CMP_EQUAL / 9 CMP_NOTEQUAL` default,
`469 / 8` testflags. The **status-only diff between my pristine and law
sweeps is EMPTY** (0 rows). The three whole-row differences against the
COMMITTED CSV appear identically in my PRISTINE sweep and are harness
artifacts, not model moves: `LowMemLib`/`LowMemPkg` `SURELOG_FAIL` notes embed
the workdir PATH, and `Earlgrey_0_1`'s dump column goes `differ` → empty,
which `verify_golden.py:521-537` returns when **`uhdm-dump` times out** (two
sweeps sharing two cores on a design that size). Earlgrey's status stays
`CMP_EQUAL` and its DATABASES are byte-identical — see the pins below.

**(5) byteverify, `SELFCHECK=1`, against MY OWN pristine workdirs.**

*uhdm2rtlil* (`evidence/byteverify_u2r.txt`): `MOVERS: 4 / 1608`, SELFCHECK
`1607 / 1608` flagged — **exactly the set predicted by name before the sweep**:

```
./default/packed_struct_array_fifo-96e8c758/slang.uhdm
./default/param_type_logic_width-76c151e4/slang.uhdm
./testflags/packed_struct_array_fifo-96e8c758/slang.uhdm
./testflags/param_type_logic_width-76c151e4/slang.uhdm
```

MOVED-WRONG 0 / AWAY 0: `param_type_logic_width` CONVERTS (0 cmp lines, 0
heads, `cmp rc=0`, both modes) and `packed_struct_array_fifo` ADVANCES —
its net vectors now agree and the head moves past them, cmp log 6446 → 6708
lines; the minted `work@packed_struct_array_fifo.d_t` lands at the SAME dump
line and the SAME span `8:28-8:31` as golden's.

*surelog* (`evidence/byteverify_surelog.txt`): `MOVERS: 6 / 960`, SELFCHECK
`959 / 960`. All six are the KNOWN pristine-nondeterministic UVM family
(`MiniAmiq`, `Scoreboard`, `SeqDriver`, `SimpleUVM`), attributed three ways in
`evidence/movers_surelog_attribution.txt`:
* ORDER-BLIND — `Scoreboard/default` is 0 lines sorted (the documented
  `svunit_pkg` `vpiTaskFunc` order coin); the other five are the documented
  4-line class, and the four lines are a constant carrying a LINE NUMBER in one
  run and `0` in the other (`UINT:821`/`vpiDecompile:821`, `UINT:1416`/…) —
  slang's macro-buffer `SourceLocation` ordering under parallel parse.
* POSITIVE CONTROL — the **pristine binary alone**, re-run, reaches several
  hashes on these rows: `MiniAmiq/default` differs against itself with the
  same 4-line class; `SimpleUVM/default` gives 2 distinct pristine hashes over
  3 runs; `MiniAmiq/testflags` gives 3; and `SeqDriver/default`'s pristine
  hash set contains `2fb39f8b4130`, **which is the law run's hash**.
* STRUCTURAL — **0** sites of either law key anywhere in the UVM trees, while
  the same two greps see both u2r witnesses (1 and 2 hits).

Every UVM row reads **0 cmp lines / 0 heads in BOTH sweeps** (`rowheads.sh`),
so the MOVER RULE's "must STAY equal" holds.

**Canaries** (`evidence/canaries.txt`). `canaries.sh` surelog `ok=50
changed=2` — the 2 are Earlgrey's dump-column timeout above, status unchanged;
u2r `ok=8 changed=0`. `ctcan2.sh` surelog `ok=58 changed=0` PASS, u2r PASS.
`canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0` PASS.
`rowheads.sh` identical between the two sweeps.

**Protected databases, law vs my pristine — every OPS pin EXACT:**

| test | default | testflags | |
|---|---|---|---|
| `SVSwitch` | `4842211c4030` | `4842211c4030` | SAME (hard byte pin) |
| `YosysVerx` | `6ccda350c24a` | `6ccda350c24a` | SAME (hard byte pin) |
| `Earlgrey_0_1` | `8bdf25272e08` | `59d0ee6d10c3` | SAME (both OPS pins) |
| `InterfaceModPort` | `59a365f3ce2c` | `59a365f3ce2c` | SAME |
| `BlackParrotComplex` | `e3e354129d5a` | `73a10e8217e5` | SAME |
| `YosysOldOr` | `d68e0796d62c` | `d68e0796d62c` | SAME |

**Fence.** The four slang-fenced tests are named in no file of this pass and
were dispatched by nothing here; `canaudit.sh` reports `FENCE-BREACH=0`.
`results/*.csv` was read only.

---

## 7. Residues + R0

* **R0 — `packed_struct_array_fifo`.** Its head has moved off the net vector
  and onto the module listing. Remaining, from the r11v29 caveat and now
  re-measurable with the nets equal: two ours-only `packed_array_typespec`s and
  a `ref_obj` golden names `work@packed_struct_array_fifo.FifoDepth.ADDR_DEPTH`
  against our `work@packed_struct_array_fifo.ADDR_DEPTH`. That is a
  localparam-scope naming question, not a net question.
* The INTERFACE face of this same habit (`u4`: the wire lands on the
  ELABORATED instance) is measured and unmodelled; it belongs with the
  interface family, not here.
* The PROGRAM and CLASS holders mint nothing (`v4`, `y3`) — modelled by
  omission, witnessed.
* The unresolvable-name arms (`w1`, `w4`, `r2`) and the plain net-declaration
  range (`r1`) show the habit reaches past type parameters. Not shipped: no
  corpus row witnesses either.
* A bare-NAME override actual mints in the **PARENT** (`r3`), a third site with
  no corpus witness.
