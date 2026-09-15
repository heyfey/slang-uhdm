# r11u41 — the STRUCT-BOUND type parameter: its net kind, its port typespec, and its variable's container

Base `6a223336`, pins as `SUPPORT_MATRIX.md` states them (slang upstream-master
`7d61e0ad1` + UHDM v1.87, Surelog v1.87 the golden producer, uhdm2rtlil v0.68).
Target: the **R0 the r11u32 landing named** — `packed_array_struct_port_sel`
plus grid arms `x_tps_nod_net` and `x_tps_pk_{in,net,out}`, the K2 remainder
that r11u32's two laws deliberately did not reach.

Everything below was measured on this pass's own builds; nothing is carried
forward from another pass's write-up.

---

## 1. The heads, re-measured at the base on this pass's own pristine build

The pristine build in this worktree is byte-identical to the main tree at the
base (`md5 a8d4ed16bcaf3a906cf2a9dc7c95dddb`).

**`packed_array_struct_port_sel`** reproduces as `CMP_NOTEQUAL` in both modes
(`decompile:`), with **ONE** head (`grep -c '^LHS:'` = 1), quoted verbatim:

```
LHS:
decompile:
ref_typespec: (work@tb.d.arr_i), id:96
|vpiParent:
\_packed_array_var: (work@tb.d.arr_i), id:95, line:5:20, endln:5:25
|vpiFullName:work@tb.d.arr_i
|vpiActual:
\_struct_typespec: (my_t), id:61, line:11:13, endln:11:62
...
RHS: <null>
```

So the corpus witness is NOT the net/var flip the R0 line led with: golden's
elaborated `arr_i` is a packed_array_**VAR**, and what we lack is the
`vpiTypespec` ref on the CONTAINER.  The order-blind whole-dump diff of the
row names three judged gaps and three unjudged ones:

| # | judged? | golden | ours |
|---|---|---|---|
| 1 | YES (`ports::Compare` reads `Typespec()`) | the port's `vpiTypedef` -> `logic_typespec 4:58` — the type parameter's DEFAULT, dims dropped, in BOTH views | `packed_array_typespec 5:12` over the struct |
| 2 | YES (the head) | `packed_array_var` carries `vpiTypespec -> struct_typespec (my_t)` | nothing |
| 3 | YES (`VpiName`) | element `struct_var`, NO `vpiName`, fullname `work@tb.d.arr_i` | element named `arr_i`, fullname DOUBLED |
| 4 | no | `struct_typespec (my_t)` endln `11:62` | `11:26` (span) |
| 5 | no | member ref fullnames `work@tb.d.T.my_t.x` | `x` |
| 6 | no | a `logic_typespec`'s `vpiParent` | different owner |

The committed grid witnesses re-measured at the base with r11u32's own
`gridread.py` reproduce its table exactly — `DEF-DIFF 2, ELAB-DIFF 6`, with
`x_tps_nod_net` golden `struct_net` / ours `struct_var` and
`x_tps_pk_{in,net,out}` golden `packed_array_net` / ours `packed_array_var`
(`evidence/grid32_pristine.txt`, calibration golden-vs-golden 0/0/0).

## 2. The producer, decoded from the pinned Surelog v1.87 tree

`NetlistElaboration::elabSignal` (`src/DesignCompile/NetlistElaboration.cpp`)
opens with `isNet = true` (:2073) and immediately clears it for a
type-parameter-typed signal (:2074-2091 — a bound `DataType` with no net
keyword).  `ElaborationStep::bindPortType_`'s type-parameter arms
(`ElaborationStep.cpp`:1505-1560) only ever call `setDataType`; the
`setType(paNetType_Wire)` that makes a `pkg::T` spelling a net lives in
`bindStructInPackage` (:1252) and is reached by nothing here.

**Exactly one thing can turn `isNet` back on**: the typespec dispatch at
`NetlistElaboration.cpp`:2135-2152, whose `uhdmstruct_typespec` arm re-asserts
`isNet = true` and runs the **LOOSE** member scan — every member's typespec a
`logic_typespec` **OR** a `struct_typespec` (a nested struct PASSES, which is
where it parts company with the strict scan `§ pkgScopedPaStructStrictNetVar88`
uses).  The typespec it scans is `compileTypespec` of the signal's type-spec
node, which for a type parameter is the parameter's **DECLARED DEFAULT**; the
instance override arrives later, through `makeVar_`/`elabTypeParameter_`, and
only decides which object the signal points at.

> **THE DEFAULT DECIDES THE KIND; THE OVERRIDE DECIDES THE TYPESPEC.**

With the kind settled, the written packed dimensions — a separate
`compileRanges` on the `Signal`, never part of that typespec — wrap the
`struct_net` in a `packed_array_net` (:2429-2444, the `PARAMETER` dtype arm).
On the variable side `makeVar_`'s `Parameter` arm (`ElaborationStep.cpp`
:1942-1957) resolves the override and hands it to
`CompileHelper::getSimpleVarFromTypespec` (`CompileType.cpp`:200-246), which
stamps the struct typespec on the inner `struct_var`, wraps it in a
`packed_array_var`, and then — at its TAIL, where `var` already names the
ARRAY — stamps the SAME typespec on the CONTAINER (:238-245).  `makeVar_` then
names only the container, which is why golden's element carries no `vpiName`.

## 3. THE GOLDEN GRID — 52 arms, and the DEFAULT is the distinguisher

`gengrid41.py` writes one module per arm (unique signal names) and a top that
instantiates all of them, so every arm has an elaborated view — an arm with no
elab view would read as *agreeing* while testing nothing.  Axes: name kind x
dims {none, packed, unpacked} x position {body net, input, output}.  Name kinds,
all reaching a struct except the controls:

| kind | the written name is |
|---|---|
| `tps` | a type parameter DEFAULTED to an all-logic packed struct |
| `tpso` | a type parameter defaulted to `logic`, OVERRIDDEN to that struct — the corpus row's shape |
| `tpsn` | defaulted to a struct with a NESTED STRUCT member |
| `tpsb` | defaulted to a struct with a `bit` member |
| `tpse` | defaulted to a struct with an ENUM member |
| `tds` / `pks` / `pksq` | a module-local / imported-bare / `::`-scoped struct typedef (controls) |

`gridread41.py` reads, per arm and per view, the object KIND, its `vpiNetType`,
its OWN `vpiTypespec`, and for a container its element's kind / name / typespec,
plus the PORT object's `vpiTypedef`.  Both producers compile the grid at
**rc 0** with no error, both dumps at rc 0 (`evidence/` and `rungrid.sh`, which
records every rc).  Calibration golden-vs-golden: **0 DEF-DIFF / 0 ELAB-DIFF /
0 PORT-DIFF**.

Golden's ELABORATED object kind:

| default binding | `T x` | `T [1:0] x` | `T x [1:0]` |
|---|---|---|---|
| all-logic packed struct (`tps`) | **struct_net** | **packed_array_net** | **array_net** |
| struct with a NESTED STRUCT member (`tpsn`) | **struct_net** | **packed_array_net** | **array_net** |
| struct with a `bit` member (`tpsb`) | struct_var | packed_array_var | array_var |
| struct with an ENUM member (`tpse`) | struct_var | packed_array_var | array_var |
| `logic`, OVERRIDDEN to the all-logic struct (`tpso`) | struct_var | packed_array_var | array_var |

and the position — body net, input, output — **is not a distinguisher** in any
row.  The nested-struct row is what proves the scan is the LOOSE one; the
`tpso` row is what proves the DEFAULT and not the resolved type is read.

Three more measured facts the grid pins:

* the `packed_array_net` carries **no** `vpiNetType`, while its `pkg::`-scoped
  neighbour `x_pksq_pk_*` carries 1 — Surelog stamps
  `getVpiNetType(sig->getType())` and a type-parameter Signal's type is the
  bare identifier, which maps to nothing.  `nets::Compare` reads VpiNetType;
* in the VAR cells the container carries the aggregate typespec and the element
  carries **no** `vpiName` — and the typedef controls `x_pks_pk_*` /
  `x_tds_pk_*` carry NEITHER, which is what makes the type-parameter leaf the
  gate rather than "a packed array of struct";
* a PORT's `vpiTypedef` is the parameter's **DEFAULT** typespec with the
  written dims dropped, in both views, at every binding — including `tpso`,
  where the default is `logic` and the resolution is a struct.

## 4. The laws

**§ tpDimPortTsIsDefault41** (`src/ModuleEmit.cpp`, the three port-typespec
sites that already served the dimension-less spelling): a PORT whose written
type is a type parameter carrying packed dims binds the ONE def-view
`typeParamDefaultTs` object, exactly as the dimension-less spelling does.  The
predicate is `tpAggregateLeafAlias41` (`src/EmitHelpers.h`): a NamedType with
packed dims whose leaf alias has `TypeAssignment` syntax and whose RESOLVED
canonical leaf is a packed struct or an enum.

**Why `portTypeParam` was not simply widened.**  It answers the same question
for `T x` only: slang hangs a named type's packed dims off the NAME, so
`T [1:0] x` parses as an `IdentifierSelectName` — the same parse split
`§ unqualDimNet9` and `§ namedTypeLeafNoNetType32` record.  Widening it would
change nine call sites at once.

**Why the AGGREGATE gate is part of the law.**  A LOGIC-VECTOR binding already
agrees at the judged level: grid cells `x_tp_pk_{in,out}` read `logic_typespec`
on both sides today (our copy is a fresh object at the port's own span, golden's
is the default's, and `typespec::Compare` reads neither span nor identity).
Firing there would re-point the port typespecs of four rows — three of them
**r11u32 conversions** — for no judged gain.

**§ tpDimAggVarSharesTs41** (`emitPackedStructArrayVar`, `src/TypeEmit.cpp`):
when the packed-array leaf is a type parameter, the element carries NO
`vpiName` and the container's fullname (it is not the "alias of an alias" the
doubled-name rule is for), and the CONTAINER gets its own `ref_typespec` — the
tail of `getSimpleVarFromTypespec`.  Both refs point at the parameter's
**ELABORATED** typespec (`typeParamElabTs`), the bare-named clone the
elaborated `type_parameter` carries, not the declaring module's typedef object:
`typespec::Compare` reads `Instance()` (UHDM v1.87 generated `typespec.cpp`:94),
and pointing them at the module typedef left the corpus row ONE head short of
equal with an `Instance` present on our side and null on golden's.  The def
view has no `typeParamElabTs` entry and keeps the typedef object, which is what
golden's def view carries there.

**§ tpDefaultStructIsNet41** (`tpDefaultStructIsNet41` in `src/TypeEmit.cpp`,
called from the elab signal loop in `src/ModuleEmit.cpp`): the net test,
asked of the parameter's DEFAULT typespec object — is it a `struct_typespec`
that passes the LOOSE member scan.  Two call sites:

* the PACKED half, a new branch placed AHEAD of the port/body split (the split
  is what hid it: a port went to the `paScoped88` routes, which refuse an
  unqualified name outright, and a body declaration to
  `emitPackedStructArrayVar`), emitting `emitPackedStructArrayNet` with the net
  type left UNSET;
* the DIMENSION-LESS half, a **measured narrowing** of the landed clause
  "a `parameter type T`-typed body declaration is always a `struct_var`".  That
  clause's reasoning — "`tps` comes back null, so the struct arm never runs" —
  holds only while the DEFAULT is not itself a struct.  Its own witness
  (`TypeParamOverride`, defaulted to a non-struct and overridden with a package
  struct) is grid cell `x_tpso_nod_net` and stays a `struct_var`.

`structTsIsNetLike` answers "does the member scan DEMOTE", so it returns true
for every non-struct typespec; the struct test is asked first, exactly as
Surelog's `ttmp == uhdmstruct_typespec` arm does.

**What the laws deliberately do NOT touch** — every one of these is a grid cell
left reading DIFF on purpose, listed again in §6:
the DEF-view typespec of a type-parameter-typed BODY net (13 cells), and
`x_tpso_unp_net`, where golden is an `array_var` and we are an `array_net`
(the suppressing direction of the same net test, with no corpus witness).

## 5. Grid result, and the conversion

| grid | calibration | pristine | patched |
|---|---|---|---|
| r11u41 (52 arms) | 0 / 0 / 0 | DEF 14, ELAB 18, PORT 10 | DEF 14, **ELAB 1**, **PORT 0** |
| r11u32's own (44 arms) | 0 / 0 / 0 | DEF 7, ELAB 9, PORT 4 | DEF 7, **ELAB 2**, **PORT 0** |

**No arm moved away** in either grid.  The 17 ELAB and 10 PORT cells that
cleared are exactly the four laws' cells; the r11u32 grid's two remaining ELAB
cells are its own R1 (`x_pklq_pk_{in,out}`), untouched.

**ONE ROW CONVERTS, both modes** — `packed_array_struct_port_sel`, the R0's own
corpus witness (§7).

### The gates (every number from this pass's own builds and sweeps)

Full listing in `evidence/GATES.txt`; the headline:

* pristine `a8d4ed16bcaf3a906cf2a9dc7c95dddb`, byte-identical to the main tree
  at the base; patched `964f049966e8d9eb627db60b4e5982c1`;
* `tests/check_goldens.sh` 23 PASS / 0 FAIL, and the `SLANG_UHDM=/bin/false`
  negative control 0 PASS / 23 FAIL;
* uhdm2rtlil **778 -> 779 CMP_EQUAL, 26 -> 25 CMP_NOTEQUAL in BOTH modes**,
  with the whole-row diff (status AND dump column) reading EXACTLY the one
  converted row per mode, against the committed baseline and against this
  pass's own pristine sweep alike;
* surelog **474/9 default and 469/8 testflags, before and after** — zero status
  changes among comparable rows.  Three non-comparable rows differ between the
  two sweeps: two `SURELOG_FAIL` detail strings that embed the sweep's own
  workdir path, and `YosysOpenSparc/default` flipping `SLANG_REJECT` <->
  `SURELOG_FAIL`, which is a golden-producer flap from running two surelog
  sweeps concurrently — re-measured SERIALLY with the patched binary it reads
  `SLANG_REJECT` with the committed baseline's own detail string;
* byte movers with `SELFCHECK` as the positive control (1607/1608 and 959/960
  flagged, so the instrument can see): **4 / 1608** in uhdm2rtlil — the two
  tests predicted BY NAME before the patched sweep ran, each in both modes —
  and **4 / 960** in surelog, all four the documented UVM coin, attributed
  order-blind and reproduced from the PRISTINE binary alone
  (`evidence/uvm_coin.txt`: four distinct MiniAmiq hashes from one binary);
* TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG per mover, order-blind and
  location-blind, calibrated golden-vs-golden-vs-golden to 0/0/0:
  **AWAY-GOLDEN 0 on all four**.  `packed_struct_array_fifo` moved toward
  golden without converting (deviation 51 -> 25 lines);
* the protected databases are byte-identical by name, all twelve: the HARD byte
  pins `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a`,
  `InterfaceModPort 59a365f3ce2c`, BlackParrotComplex, YosysOldOr, and
  `Earlgrey_0_1` at both of its pins (testflags `59d0ee6d10c3`, default
  `8bdf25272e08`).  Earlgrey_0_1's canary row reads `changed` on the DUMP
  COLUMN alone (`CMP_EQUAL/differ -> CMP_EQUAL/`), the documented uhdm-dump
  timeout draw; against this pass's own pristine sweep the canaries read
  `ok=52 changed=0`;
* canaries uhdm2rtlil `ok=8 changed=0`, `ctcan2` PASS on both corpora,
  `canaudit` `audited=29 UNCOVERED=0 FENCE-BREACH=0`;
* `rowheads.sh` on the patched workdir: SeqDriver, SimpleUVM, Scoreboard,
  MiniAmiq, BuildUVMPkg and Earlgrey_0_1 all **0 heads** in both modes;
  Rggen/default 1 head (unchanged family).

## 6. Residues measured here and NOT touched

* **The DEF-view net typespec of a type-parameter-typed BODY declaration.**
  Golden's def-view `logic_net` carries the parameter's DEFAULT typespec with
  the written dims dropped — the same object the port half now binds — where we
  mint a fresh `logic_typespec` at the name (`T x`, `T x [1:0]`) or a
  `packed_array_typespec` (`T [1:0] x`).  13 grid cells:
  `x_{tps,tpsb,tpse,tpsn}_{nod,pk,unp}_net` and `x_tpso_pk_net`.  No corpus row
  is waiting on it — the two nearest (`packed_struct_array_fifo`,
  `port_chained_type_param`) have heads on unrelated faces (an anonymous
  `struct_typespec`, a constant's `int_typespec`).
* `x_tpso_unp_net` — `T x [1:0]` with a `logic` default overridden to a struct:
  golden `array_var`, we `array_net`.  The SUPPRESSING direction of
  § tpDefaultStructIsNet41, in `unpackedArrayLeafIsNet`.
* `x_pksq_unp_net` — an unpacked dim on a `::`-scoped struct typedef: golden
  stamps `vpiNetType 1`, we print none.  Pre-existing, the same family as
  r11u32's R2.
* `x_pklq_pk_{in,out}` — r11u32's R1, unchanged.

## 7. The conversion, quoted

`results/gate_uhdm2rtlil.csv:547` reads

```
packed_array_struct_port_sel,testflags,CMP_NOTEQUAL,decompile:,,
```

and the patched sweep reads, in BOTH modes

```
packed_array_struct_port_sel,default,CMP_EQUAL,,,differ
packed_array_struct_port_sel,testflags,CMP_EQUAL,,,differ
```

## 8. Reproducing

```bash
# the grid (both producers, every rc recorded)
python3 gengrid41.py grid41.sv
SLANG_UHDM=<binary> bash rungrid.sh grid41.sv <tag>
cd run_<tag>
python3 ../gridread41.py g.raw g.raw | tail -1   # CALIBRATION: 0/0/0
python3 ../gridread41.py g.raw o.raw

# the a-priori mover prediction, from the SOURCES, before any patched sweep
python3 predict41.py ~/git-repos/uhdm2rtlil/test
python3 predict41.py ~/git-repos/Surelog/tests ~/git-repos/Surelog/third_party/tests \
  | grep -v -F -f <file holding the fenced names, one per line>
```
