# r10earl96 — § elabRhsOpElemTdAliasBare96

**A `param_assign`'s Rhs ASSIGNMENT-PATTERN operation is re-minted against the
INSTANCE, so the element typespec its own array clone carries takes the
CLONE-flavoured LAW-S copy — the one whose `Typedef_alias` target is BARE —
always, and never the package-qualified listing object the parameter's own
typespec may still name.  A Rhs CONCATENATION is a different Surelog row and
keeps the Lhs's rule: the clone copy only on a MATERIALIZED IMPORT.**

> **Amended by the verifier (`tools/probe/r10vearl96repro/`).**  The law as
> first written applied to BOTH triggers of the guarded arm and turned two
> right cells wrong on a concat-initialised parameter; §3 below carries the
> shipped expression.  Everything else in this document re-measured bit for
> bit.

BASE `a8876a8`, branch `auto5h`.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; every
instrument in this directory is MEASUREMENT ONLY.

---

## 1. The head this pass took

`Earlgrey_0_1`, **both modes**, ONE head each, ONE shared object, re-measured
on this pass's own pristine build `3b10fa70b3a1` (`HEAD_BEFORE_*.cmp`; 56
stderr lines per mode — r10earl95 recorded 112 because it counted uhdm-cmp's
stdout copy of the same subtree alongside its stderr one).

```
hmac_pkg.sv:17   typedef logic [31:0] sha_word_t;

LHS (golden)  logic_typespec  VpiName `sha_word_t`
                              VpiParent -> ref_typespec (work@top_earlgrey.u_hmac.sha_word_t)
                              VpiInstance -> package hmac_pkg
RHS (ours)    logic_typespec  VpiName `hmac_pkg::sha_word_t`
                              VpiParent -> module_inst work@top_earlgrey.u_hmac
                              VpiInstance -> package hmac_pkg
```

Same kind, same range (31:0, both constants identical), same instance — the
head is `VpiName`, the FIRST field `typespec::Compare` reads
(`~/git-repos/UHDM/build/generated/src/typespec.cpp`: `VpiName`, then
`Typedef_alias`, then `Instance`).

### The position, read out of both arenas (`pa96`, this directory)

`pa96 <db> work@top_earlgrey.u_hmac InitHash` walks the param_assign's two
typespec chains link for link:

```
GOLDEN                                      OURS (pristine)
pa 456356 lhs=InitHash rhs=operation        pa 362706 lhs=InitHash rhs=operation
 RHS ref_typespec 456390                     RHS ref_typespec 362716
  array_typespec 456391                       array_typespec 362717
   ELEM ref_typespec 456397                    ELEM ref_typespec 362723
    logic_typespec 456398 `sha_word_t`          logic_typespec 772209 `sha_word_t`
     ALIAS ref_typespec 456399                   ALIAS ref_typespec 772210
      logic_typespec 456400 `sha_word_t`  <-HEAD  logic_typespec 27866 `hmac_pkg::sha_word_t`  <-HEAD
       INSTANCE package hmac_pkg                   INSTANCE package hmac_pkg
 LHS ...                                     LHS ...
   ELEM logic_typespec 1017329 `sha_word_t`    ELEM logic_typespec 772235 `sha_word_t`
     ALIAS logic_typespec 1017331 `sha_word_t`  ALIAS logic_typespec 772212 `sha_word_t`   <- already right
```

Our **Lhs** chain was already golden's — `§ importElemBareTdAlias` (r10earl16's
`importElemTdRefs16`) gives the parameter's own element copy a clone-flavoured
bare alias target on a materialized-import row.  Our **Rhs** chain was not: the
operation's array clone is minted at `ParamEmit.cpp:13135` with
`importedParamElemClone16` left false, so its element took LAW S's memoized
HOME copy, whose alias points back at the module's QUALIFIED Typespecs listing
entry (id 27866 — the very object the module lists as
`logic_typespec hmac_pkg::sha_word_t`).

---

## 2. The decoded model (Surelog)

`UhdmWriter::writeDataTypes` (`src/DesignCompile/UhdmWriter.cpp:775-796`) is
the ONLY place a typespec's name acquires a package qualifier:

```cpp
if (parent->UhdmType() == uhdmpackage) {
  if (tps && (tps->VpiName().find("::") == std::string::npos)) {
    const std::string newName = StrCat(parent->VpiName(), "::", tps->VpiName());
    tps->VpiName(newName);                 // IN PLACE, on the shared object
  }
}
```

Three consequences, each of which this pass measured rather than assumed:

1. The qualifier is **owned by the package listing walk**, not by the typedef.
   A module's `Typespecs` listing shows `hmac_pkg::sha_word_t` because it holds
   the very object `writePackage` renamed (packages are written first);
   anything Surelog RE-COMPILES in the module's own scope comes back BARE.
2. `writeImportedSymbols` (:1307-1396) clones and re-names only for an
   **explicit** single-symbol import (`item->Item()`'s decompile is the symbol
   name).  `module hmac import hmac_pkg::*;` carries `"*"`, no package typespec
   matches it, and nothing is cloned — so the bare copies under `u_hmac` are
   NOT import clones; they are the ordinary per-declaration re-compilation LAW
   S already models.
3. Golden's `<instance>.<typedef>` "alias" is not a name at all: the dump
   SYNTHESIZES `work@top_earlgrey.u_hmac.sha_word_t` for the `ref_typespec`
   from its parent chain.  The parent differs on our side too, but no generated
   `Compare` reads `VpiParent` (RESUME §9) — the parent was the CLUE, the name
   was the head, and they are one decision.

### Where the Rhs splits from the Lhs — the measured distinguisher

`g5_neg96.sv` declares BOTH shapes in one module (`m5loc96` wildcard-imports
`p5n96` and also declares its OWN `localparam n_t LOCARR[4]`).  Golden's
elaborated `work@top5n96.u_l`:

| position | golden alias target |
|---|---|
| `pa[LOCARR].lhs>r>e>r` (module's OWN declaration) | `n_t -> p5n96::n_t` **qualified** |
| `pa[LOCARR].rhs>r>e>r` | `n_t -> n_t` **bare** |
| `pa[PKGARR].lhs>r>e>r` (materialized import copy) | `n_t -> n_t` **bare** |
| `pa[PKGARR].rhs>r>e>r` | `n_t -> n_t` **bare** |

The **Lhs** splits on the import (which is exactly what
`§ importElemBareTdAlias` already encodes); the **Rhs pattern never does**.
That is why the PATTERN arm's flag is unconditional.

The **Rhs CONCATENATION** is the other half of the same guarded site, and it
DOES split on the import — measured on `../r10vearl96repro/v7_concat96.sv`,
one module declaring both shapes of one imported typedef:

| position | init | golden alias target |
|---|---|---|
| `pa[WPAT].rhs>r>e>r` (module's own) | `'{…}` | `x_t -> x_t` **bare** |
| `pa[WCAT].rhs>r>e>r` (module's own) | `{…}` | `x_t -> p7x96::x_t` **qualified** |
| `pa[PKGPAT].rhs>r>e>r` (import copy) | `'{…}` | `x_t -> x_t` bare |
| `pa[PKGCAT].rhs>r>e>r` (import copy) | `{…}` | `x_t -> x_t` bare |

A package view is not a boundary this flag has to carry: BOTH triggers already
carry `!inPackage` in their own definitions (`:12874` and `:12984`), so
`!inPackage` is a tautology at this site.

---

## 3. The law

`src/ParamEmit.cpp`, at the elaborated Rhs operation's array-typespec mint
(the `unpackedArrayTs9 || unpArrConcatTs9` arm):

```cpp
bool savedIpc96 = importedParamElemClone16;
importedParamElemClone16 = unpackedArrayTs9 || (isImported && !inPackage);
rt->Actual_typespec(makeUnpackedArrayParamTs(ps, tsPrefix, rt, nullptr, true,
                                             tsPrefix));
importedParamElemClone16 = savedIpc96;
```

`unpackedArrayTs9` is the ASSIGNMENT-PATTERN trigger (unconditional);
`isImported && !inPackage` is the CONCAT trigger, the same predicate
`§ importElemBareTdAlias` uses at `:4897`.

That flag is the one `makeUnpackedArrayParamTs` (:15086) already reads to
record the element ref in `importElemTdRefs16`, which the design-final
`§ importCloneBareTdAlias16` rebind (`TypeEmit.cpp:7251`) turns into the
clone-flavoured copy: bare name, `Typedef_alias` -> a BARE target.  **Nothing
else changed** — no new object kind, no new name spelling, no parenting change.
The pass is a REFUSAL to hand this one position the home copy.

---

## 4. Measurements

### 4.1 The head

| row-mode | pristine `3b10fa70b3a1` | patched `786defd3edcb` |
|---|---|---|
| `Earlgrey_0_1` default   | 56 cmp lines, 1 head — the `sha_word_t` name | 16 cmp lines, 1 head — **a new object** |
| `Earlgrey_0_1` testflags | 56 cmp lines, 1 head — the same object | 27 cmp lines, 1 head — **a new object** |

The two modes shared ONE head before and now have two DIFFERENT ones
(`HEAD_AFTER_*.cmp`): default lands on `LHS: <null>` against a surplus
`logic_var fifo_wptr` in `u_msg_fifo.gen_normal_fifo`; testflags on an
`int_typespec`'s `VpiSigned` at `prim_packer.sv:31`.  Both are recorded as R0
below.

### 4.2 The corpus census (`ct96cen` + `score96.py`, this directory)

Three families, keyed TOP-DOWN from a named root by the FIELD PATH the walk
took — never by `vpiParent`, because the two producers park these objects on
different parents and no generated `Compare` reads it:

* **TS** every typespec reachable from a `module_inst` / `interface_inst` /
  `package` through `Param_assigns` (Lhs and Rhs), `Parameters`, `Nets`,
  `Variables` and the root's own `Typespecs`, following
  `ref_typespec -> Actual_typespec`, `Elem_typespec` and `Typedef_alias`;
  payload = kind + `VpiName` + vpiInstance name.
* **AL** the alias-chain projection: own name -> alias-target name.
* **GA** the GLOBAL tripwire: EVERY named typespec in the arena, keyed by kind
  + span + name, so a rename anywhere — inside the walked paths or outside
  them — shows up as a bucket delta.

`score96.py` joins the two sides as a MULTISET (keys collide; a last-writer
dict drops rows).

**THE DENOMINATOR, measured on the PRISTINE sweeps before a line of the law was
written** (`pop96.sh`, `POP_*.txt`): every golden alias-chain row that reaches
an array ELEMENT, in both corpora:

```
uhdm2rtlil   28 rows over 1358 databases, in 3 tests
             (TypedefVariableDimensions, unpacked_struct_array_typedef,
              VarPassedTo2Submodules) — every one a struct_typespec or
             enum_typespec element, the AGGREGATE kinds LAW S never copies,
             and NOT ONE of them on a `pa[...].rhs` path.
surelog     218 rows over 956 databases: 192 in Earlgrey_0_1 (96 per mode) and
             26 in HierPathVarArray / PackedEnumPort / TypedefUnpacked /
             VarRangeTypedef — again all struct/enum elements.
```

Of Earlgrey's 96 rows per mode, **8 differ and 88 already agree**; the 8 are
the law's whole population:

```
work@top_earlgrey.u_hmac            pa[InitHash].rhs>r>e>r   and pa[CubicRootPrime].rhs>r>e>r
work@top_earlgrey.u_hmac.u_hmac     "                        "
work@top_earlgrey.u_hmac.u_sha2     "                        "
work@top_earlgrey.u_hmac.u_sha2.u_pad "                      "
    golden  logic_typespec sha_word_t -> sha_word_t
    ours    logic_typespec sha_word_t -> hmac_pkg::sha_word_t
```

**PREDICTION, made from the pristine databases only: EXACTLY TWO DATABASES MOVE
— `Earlgrey_0_1` default and testflags.  uhdm2rtlil: ZERO movers.**

Re-scored over the SAME fixed universe after the patch, golden side asserted
byte-unchanged:

| Earlgrey | BOTH-SAME | MOVED-WRONG | GOLDEN-ONLY | OURS-ONLY |
|---|---|---|---|---|
| default   pristine | 81 972 | 24 | 753 | 291 |
| default   patched  | **81 988** | **8** | **753** | **291** |
| testflags pristine | 97 224 | 24 | 753 | 6 500 |
| testflags patched  | **97 240** | **8** | **753** | **6 500** |

**WRONG→RIGHT 16 rows per mode (the 8 cells, each seen by the TS and the AL
family), RIGHT→WRONG 0, AWAY-GOLDEN 0, and NEITHER one-sided set moves by a
single row.**  The 8 MOVED rows that remain in both modes are pre-existing and
belong to other laws (`spi_byte_t`'s GA count, `u_flash_mp`'s `BankW`
vpiInstance, `u_pinmux`'s `MioPeriphHasSleepMode` Rhs kind).

The whole-corpus pristine censuses (`CEN_pris_*.buckets`, 956 + 1358
databases) are kept as the before-picture: surelog BOTH-SAME 428 500 /
MOVED-WRONG 316 / GOLDEN-ONLY 32 447 / OURS-ONLY 20 171; uhdm2rtlil 156 181 /
12 / 5 286 / 376.

### 4.3 The grids

Five purpose-built arms, each built by Surelog and by BOTH frozen binaries in
BOTH views (`arm96.sh`; every child `</dev/null`, every rc printed), scored
against the SAME golden:

| arm | grid axis | plain pris → patc | elab pris → patc |
|---|---|---|---|
| `g1_kind96` | typedef KINDS: logic vector / enum / packed struct / packed array / typedef-of-a-typedef, plus a scalar (non-array) control | MOVED 30 → **26** | 30 → **26** |
| `g2_form96` | import FORMS: wildcard / explicit single-name / scoped use with NO import / `$unit` import | 10 → **0** | 10 → **0** |
| `g3_site96` | use SITES: port / net / variable / parameter (scalar + array) / cast target / nested typedef / function return + io_decl | 8 → **4** | 8 → **4** |
| `g4_home96` | HOMES: module top / submodule / gen scope / interface / three instantiations of ONE span | 10 → **0** | 10 → **0** |
| `g5_neg96` | the NEGATIVE controls: the package's own two views, a module-LOCAL typedef, a module's own localparam of an imported typedef | 11 → **7** | 11 → **7** |

`GOLDEN-ONLY` and `OURS-ONLY` are **byte-identical before and after on every
arm and every view** — the law adds and removes no object.

Every remaining MOVED cell was decoded and belongs to a DIFFERENT law; they are
listed as R1–R3 below.  In particular `g2` proves the law is right for all four
import forms including a SCOPED USE WITH NO IMPORT AT ALL, and `g4` proves it
for an interface and for three instantiations of one span.

### 4.4 Gates

All green — `GATES.r10earl96.txt` carries the raw output.  In one line each:

* build both, md5 separately: pristine `3b10fa70b3a1`, patched `786defd3edcb`,
  0 errors, both frozen `chmod 555` at immutable paths of the SAME LENGTH.
* goldens **23 PASS / 0 FAIL** on the patched binary and on the pristine one,
  **0 PASS / 23 FAIL** on `/bin/false` (the negative control fires).
* uhdm2rtlil both modes **679 / 50 / 2**; `ct8rows` **PASS** against the
  committed baseline and against this pass's own pristine sweep, testflags and
  default, status column AND dump column.
* surelog `--mode both`: **471/466 CMP_EQUAL, 10/9 CMP_NOTEQUAL** — unchanged;
  `ct8rows` **0 differing rows over 1588** against the committed baseline and
  against this pass's own pristine sweep.  **NO row is converted**;
  `Earlgrey_0_1` stays `CMP_NOTEQUAL` in both modes and `results/*.csv` is not
  touched.
* `cmds.txt` audited BY BINARY PATH: **0 of 3146 + 2924** name the main-tree
  binary.
* `byteverify SELFCHECK=1`: uhdm2rtlil **MOVERS 0 / 1358**, surelog **MOVERS
  2 / 956** — `./default/Earlgrey_0_1` and `./testflags/Earlgrey_0_1`, both
  PREDICTED BY NAME from the pristine census before the law was written.
  SELFCHECK flags 1357/1358 and 955/956, so the comparator can see.
* canaries `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2` PASS / PASS;
  `canaudit.sh canaries.sh ctcan2.sh` from THIS directory
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`.
* byte pins hold: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`,
  InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical.
* `rowheads.sh`: **Earlgrey 112 → 31 (default) and 112 → 54 (testflags)**, one
  head each; SeqDriver / SimpleUVM / Scoreboard / MiniAmiq 36, BuildUVMPkg 30,
  Rggen 0 — every other family unmoved.
* boundaries: OWN `PROCESSED=5 identical=6 DIFFERING=4` (g1 and g2, both
  views); WIDE `PROCESSED=4355 identical=8348 DIFFERING=6` — g1, g2 and
  `r10earl_repro/te.sv`, the arm r10earl16 built for the sibling law, which
  goes **MOVED-WRONG 5 → 1** in both views with both one-sided sets unchanged.
  The wide rc histogram is symmetric side for side (`rc=0 7987/7987`,
  `rc=3 342/342`, `rc=4 367/367`, `rc=139 14/14`).  **Nothing outside this
  law's population differs anywhere in the probe tree.**

Note on the OWN boundary: `g3`, `g4` and `g5` dump IDENTICALLY on the two
binaries even though their census cells move — `uhdm-dump` ABBREVIATES an
already-visited typespec, so an alias TARGET's name is invisible in a dump diff
while `typespec::Compare` reads it.  That is why this pass is scored by the
census and by the official `uhdm-cmp`, never by dump bytes.

---

## 5. Reproducing

```
g++ -O2 -std=c++17 <ct96cen|ts96|pa96>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <name>
```

* `pa96 <db> <instance fullname> [param]` — the param_assign chains above.
* `ts96 <db> <name substring>` — every object carrying a name, with its alias,
  its vpiInstance and its parent chain.
* `ct96cen <db>` — the three census families.
* `score96.py <golden.cen> <ours.cen> [limit]` — the multiset join.
* `cen96.sh <sweep-workdir> <out-prefix>` (env `CEN96`, `SC96`) — the whole
  corpus, one bucket line per database plus every differing cell.
* `pop96.sh <sweep-workdir> <out>` (env `CEN96`) — the denominator scan.
* `arm96.sh <arm.sv> <outdir>` (env `PRISTINE_BIN PATCHED_BIN CEN96`).
* `vwide96.sh <filelist> <out-prefix>` (env `PATCHED_BIN PRISTINE_BIN
  PROBE_ROOT`) — the wide boundary.
