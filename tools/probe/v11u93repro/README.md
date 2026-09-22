# v11u93 — r11u101's adversarial verifier: ACCEPT-WITH-FIX

**Verdict: ACCEPT-WITH-FIX.** r11u101's LAW A (§ `caNestedModPortedDefShell101`)
and LAW B (§ `caNestedModDefKeyScoped101`) reproduce bit for bit. They are
correct on every non-library shape tried here, and they also clear four
pristine SEGFAULTS. They broke one legal shape: the **library unit**. A nested
module inside a `-v` library file got a def view that golden never writes.
Pristine was right there and the unguarded law was wrong (3 arms). The fix is
one guard, § `caNestedModLibUnusedNoDef101V`, in `src/UhdmExporter.cpp`.
It can be dropped alone with `R11U101_NESTLIB_OFF=1`.

Base `e29d5182`. Pins per `SUPPORT_MATRIX.md`.

| binary | md5 |
|---|---|
| pristine (own worktree, `-j 2`) | `c566d68304a691a704d2d4f80493ad79` — equals the OPS pin |
| r11u101 law (its patch, applied to a fresh `e29d5182`) | `1b79bf536de130c3c2640e68519803b9` — equals the implementer's |
| **fixd** (law + the guard) | `249f8d84733c73ff63993a6862db096f` |

## 1. The break: a nested module inside a library unit

Surelog's writer drops every library-file `ModuleDefinition` that the design
does not use: `~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:5111-5116`.
`designComponents` is the set of definitions in the elaborated instance tree
(`:4858-4884`). Surelog never mints slang's implicit nested instance, so a
nested module is "used" only when a WRITTEN instantiation elaborates it.
`addDefOnlyModule` already declines library units for the file-scope road.
r11u101's two roads did not.

| arm (`grid/`) | pristine | r11u101 law | fixd | distsec pris / law / fixd |
|---|---|---|---|---|
| `b13_libouter` (ported nested, `-v lib.sv`) | **0 (CMP_EQUAL)** | **449** | **0** | 0 / 49 / 0 |
| `b13f_libmixed` (+ param nested) | **0 (CMP_EQUAL)** | **786** | **0** | 0 / 92 / 0 |
| `b13c_librv2implicit` (LAW B, implicit only) | 359 | 380 | 359 | 17 / 34 / 17 |
| `b13d_librv2explicit` (LAW B, WRITTEN instances) | SEGFAULT | 0 | **0 (kept)** | — / 0 / 0 |
| `b13e_libportedinst` (control) | 0 | 0 | 0 | 0 |

On the three fixed arms, fixd's databases are byte-identical to pristine's.
The implementer's slot scorer is BLIND to `b13_libouter`: `slot101.py move`
reads MOVED-WRONG 0 on it, because an invented entry is OURS-ONLY and never
had an OK slot to lose. The display-free sectioned distance (`distsec`) and
the judge both see it.

The rule: a nested definition whose syntax tree is a library unit (or whose
`sourceLibrary` is not the default) is admitted **only through a written
instance**. LAW A declines such a definition before `createDefault`, so
nothing is minted. LAW B declines when the found instance is slang's implicit
one (`implicitNestedInst99`).

## 2. What reproduced (the implementer's headline numbers)

All of these reproduced with the same binaries:
- r11u101 grid: 9772 → 1667; `R11U101_OFF=1` gives 9772.
- aoff 8128, boff 3311, soff 2119.
- w23 444 → 0, w24 446 → 0, w19 438 → 0, x09 390 → 0.
- x15 507 → 527, where the `sub::innermod` entry goes 16 → 0 and no other entry moves.
- x19 and x25 at 55.
- Slot scorer: GAINED 886, MOVED-WRONG 0. distsec 1289 → 249.
- r11u99 distsec 1392 → 1279.

Across the 8 control grids (233 buildable arms), the law moves only its own
19 arms plus w19, w23 and w24. `R11U101_OFF=1` equals pristine bytes on
233/233, and fixd equals law bytes on 233/233.

## 3. The break grid (`grid/`, 39 arms, `evidence/GRIDV93.txt`)

The grid covers:
- **Sibling nesting.** A ported nested module instantiates a parameter-overridden sibling.
- **Upward references into the outer.** The outer's parameter sizes a port, the outer's typedef types a port, and the body reads the outer's net.
- **Face families**, each in its own arm: strengths and delays, net-decl-assign with strength, `always_ff`/`always_comb`/function/localparam, package struct port, generate loop, body-only parameter, an interface instance inside.
- **Outer instance counts of 1, 2 and 3**, an outer instance array, and an outer reached only through a non-taken generate.
- **Tops.** A second top, and `--top`/`-top`.
- **LAW B variants.** Written instances in both outers, a generate-wrapped instance, an instance array, depth 2 in both outers, one outer explicit and one ported.
- **Shadow faces.** A file-scope `innermod` instantiated in `dut`, next to a ported or portless nested one.
- **Library faces.**

**Pristine-right → fixd-wrong: 0.** Per slot, pris → fixd reads MOVED-WRONG 0
and GAINED 1465. Against the unguarded law, pris → law reads MOVED-WRONG 42
(`b13f`). Every arm with `R11U101_OFF=1` reproduces pristine's databases
byte for byte.

**The law clears four pristine segfaults** (pristine rc 139, fixd rc 0):
`b05`, `b06`, `b07` and `b13d`. These are LAW B shapes with written
instances. `b05`, `b07` and `b13d` reach CMP_EQUAL.

## 4. Census: golden first (`evidence/CENSUSV93.txt`)

`dbcenv93.sh` restores every GOLDEN the sweeps name (1742 u2r and 1524
surelog databases), using the implementer's `ct101cen`. The positive control
is x09, which hits on golden and on pristine.

- **12 surelog goldens DO hold a nested definition**:
  - Attributes: `top::top2`
  - BadLabel: `test::sub`, `test::sub2`
  - Escape, SplitFile and TimeUnit: `middle::nested`
  - UnitElabExternNested: `dff_nested::ff1`, `ff2`, `ff3`

  Each of these tests appears in both modes.
- The implementer's census, which read OUR databases only, missed them.
- All 12 are genuine SLANG_REJECT rows: rc 3, or rc 2 for TimeUnit testflags, on both binaries. None has a database, so none can move. These are the shapes the laws would reach once slang accepts the sources.
- Our databases hold no nested definition: 0 of 960 surelog and 0 of 1608 u2r, on both binaries.
- The source trace (`cellcen101.py`, fixd, `R11U101_NETDBG=1`) finds 0 corpus trace lines. `nestAny=8` comes only from the three seeds.
- The six `rc=-11` census arms (rp32 ×3 testflags, Tnoc both modes, Rggen testflags) SEGFAULT identically on PRISTINE. They are pre-existing, and the CSV records them as SLANG_REJECT or SURELOG_FAIL.

**Movers predicted by name, a priori: none from the laws.** The only
expected movers were the UVM family's documented nondeterminism.

## 5. Gates (`evidence/GATESV93.txt`)

- **Goldens:** 23/0, and 0/23 with `/bin/false`.
- **cmds.txt:** each of the 4 workdirs names only its own frozen binary (1531 slang invocations per surelog workdir, 1742 per u2r workdir). The main tree appears 0 times.
- **u2r, both modes:** PASS against `golden_uhdm2rtlil.csv` and `gate_uhdm2rtlil.csv`. fixd's CSV equals pristine's. byteverify: 0/1608 movers.
- **surelog, both modes:** status identical (474/9 and 469/8). The only differing rows are:
  - LowMem* testflags, where the detail carries the workdir path.
  - Earlgrey both modes, where the dump column is blank. This is a uhdm-dump timeout under load. Pristine's sweep reads the same, and the DB pins hold.
- **byteverify, surelog:** 3/960 movers: MiniAmiq in both modes and SimpleUVM/default.
  - Each is a 4-line UINT/vpiDecompile difference that order-blind reading does not remove.
  - POSITIVE CONTROL: rerunning pristine self-moves MiniAmiq in both modes, SimpleUVM/default and SeqDriver/default. The rerun's SimpleUVM hash equals fixd's.
- **Pins:** SVSwitch, YosysVerx, InterfaceModPort, Earlgrey (both modes), BlackParrotComplex and YosysOldOr are byte-equal between pristine and fixd.
- **Canary scripts:**
  - `canaries.sh`: ok=50 changed=2, the two Earlgrey dump-column blanks, which pristine shares.
  - u2r: ok=8.
  - `ctcan2.sh`: PASS twice.
  - `canaudit.sh`: PASS.
- **Wide boundary** (4473 arms, PROCESSED==LISTED): 11 non-law movers, all attributed.
  - 3 binary-image UINT arms (+4160). With `R11U101_OFF=1` the same binary moves them the same way.
  - 8 order coins: pristine disagrees with itself, and order-blind reading shows 0 lines. r10uvm88 is new versus the implementer's list; its boundary draw was a pristine `vpiTaskFunc` order flip.
  - 0 trace lines.

## 6. Residues (ranked)

1. **LAW B's other half: the FILE-SCOPE definition dropped by a nested one.** Seen in `b12` (458 on all three binaries) and `b14`. A nested portless `innermod` takes the bare key first, so the file-scope `work@innermod` that `dut` instantiates loses its def view. golden lists both. This is the brief's "re-key at ENTRY", which the post-hoc re-entry does not do. `b14`'s judge rise (562 → 616) is the head moving: distsec drops 66 → 18, with 0 slots moved wrong.
2. **The def-only road writes `vpiNetType` on a typedef- or struct-typed port net, and golden does not.** Seen in `b03` and `b09d`, at 15 lines each. This is PRE-EXISTING: the file-scope control `c09d_pkgstruct_genonly` shows the same OURS-ONLY slot on pristine. The laws inherit it by reusing the road.
3. **r11u101's R0.** A module reached only through an unelaborated body has no def-view ports. This covers `b23` (a parameter with no default), x19 and x25.
4. **`b06`.** golden names an instance inside a generate block `work@dut.u_b.g::innermod`. Pristine segfaulted on this arm; the law reaches 94.
5. **The admission refusals x04 and x17, and the fenced RV1 elaborated face x15.** These are unchanged.

## Reproduce

```
cp -r tools/probe/v11u93repro/grid /tmp/g93
for t in pris fixd; do GRID=/tmp/g93 bash tools/probe/v11u93repro/rrv93.sh <bin_$t> $t; done
R11U101_NESTLIB_OFF=1 GRID=/tmp/g93 bash tools/probe/v11u93repro/rrv93.sh <fixd> liboff
CT=<built ct101cen> bash tools/probe/v11u93repro/dbcenv93.sh <sweep workdir> <tag>
REPO=. python3 tools/probe/v11u93repro/replayv93.py surelog <workdir> <scratch> <bin>... -- Name/mode ...
PRIS=<bin> LAW=<bin> bash tools/probe/v11u93repro/attrv93.sh <arm dir>...
```
