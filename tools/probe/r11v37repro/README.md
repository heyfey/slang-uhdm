# r11v37 — adversarial verification of r11u37 (§ typeParamNameMintsDefNet37)

Base `34b04279`. Worktrees `/tmp/wt_v11u37` (law + fix) and `/tmp/wt_v11u37pris`
(pristine), both built by the verifier, `-j 2`, frozen `chmod 555`:

| binary | md5 |
|---|---|
| pristine (mine) | `c8d72796d4550874084656de68f7b845` — byte-identical to the main tree's `build/slang-uhdm` at 34b04279 |
| r11u37 as submitted | `4c10c4bae1347ce2e1e0916d64596866` — reproduces the implementer's md5 |
| r11u37 **+ the three verifier gates** | `3401e58a790ad881cc226f32eb33d3b3` |

Every `cmds.txt` in every sweep workdir was audited by BINARY PATH
(`pris_u2r` 1742/1742 = `/tmp/v11u37_pris.bin`, `law_u2r` 1742/1742 =
`/tmp/v11u37_law.bin`, and likewise for the fixed sweep).

---

## 1. What the verification found

The producer decode is CORRECT and was re-read at the Surelog source: the mint
arm in `UhdmWriter::lateBinding` (`Surelog/src/DesignCompile/UhdmWriter.cpp`,
`lateBinding` at :3297) makes a bare `logic_net` with the reference's span,
`VpiNetType(getVpiNetType(defaultNetType))`, NO typespec, and
`nets->push_back(net)` after every declared net — exactly the object the patch
mints, in exactly that position (v-grid `a13`: golden's order is
`d_i, d_o, n1, n2, b`; the patch's order is the same).

The submitted law is nevertheless **pristine-right → patched-wrong on three
legal-SV faces**, all found by an independent 39-arm golden grid
(`vgrid.sh` + `vgrid2.sh`, both with a positive and a negative control):

| arm | source shape | golden | pristine | r11u37 | + gates |
|---|---|---|---|---|---|
| `a1` | POSITIONAL override `c #(logic [$bits(a)+$bits(b)-1:0]) u (…)` | no net | no net | **mints `c_a1.b`** | no net |
| `b8`/`c2`/`c3` | `localparam type dt2 = d_t;` inside a named generate block / an unnamed conditional generate / a generate `for` | no net | no net | **mints `d_t`** | no net |
| `c4` | `parameter type dtype = d_t` on a module declared INSIDE another module | no net | no net on the outer def | **mints `outer_c4.d_t`** (wrong holder) | no net on the outer def |

The three gates that close them (`src/ModuleEmit.cpp`, inside
`collectTypeParamLateBindNets37`):

* **GATE A** — the walk stops at a NESTED `module`/`interface`/`program`/
  `package`/`class`/`checker` declaration, so an inner header's default is
  never filed on the enclosing module's def.
* **GATE B** — clause (1) does not fire inside a generate scope
  (`IfGenerate`, `LoopGenerate`, `CaseGenerate`, `GenerateRegion`,
  `GenerateBlock`). Body-level `localparam type` still mints (arm `c1`), and
  an INSTANTIATION inside a generate still mints (arm `a2`) — the flag gates
  only the type-assignment clause.
* **GATE C** — clause (2) reads a NAMED `.dtype(…)` override only;
  `OrderedParamAssignment` is dropped.

**The gates are a no-op on both corpora**: the fixed binary's uhdm2rtlil
databases are byte-identical to the submitted law's (same 4 movers, same four
hashes `300e3dbddb67` / `f49f09966695` / `8e284c9f0ef4` / `5cfef1662777`).

## 2. The golden grid (39 arms; `evidence/goldengrid_A_B.txt`, `goldengrid_C.txt`)

Controls: arm `pc` (the corpus witness reduced to one file) MUST mint
`work@c_pc.b`; arms `nc`/`nc2` name a missing source and must read
`rc!=0 holders=0 ARM COMPILED NOTHING` — `compiled-nothing` is exactly 1 in
each run, so no arm's silence is a failed compile. Every arm prints its rc and
its top-level holder count. Arm `a9` reads `rc=4` and is scored INCONCLUSIVE.

Faces the implementer's grid did not carry, and what golden says:

* ordered override → **no mint** (`a1`); ordered with a constant range → no
  mint either way (`c8`).
* instantiation inside a generate → golden mints **BOTH** names (`a2`); a
  genvar in the bound → golden mints the `$bits` leaf that is exempt outside a
  generate (`a12`); a generate-LOCAL signal in the bound → golden mints both
  (`c5`). The shipped law mints a subset of these — a MISS, never a wrong
  object.
* two parents minting into one child (`a3`), two instantiations in one parent
  (`a4`), a two-dimensional actual (`a5`, one net, first span), a function call
  in the bound (`a8`), a local variable (`a11`), a child that declares nets
  (`a13`): law == golden, **order included**.
* `struct packed {…}` and `named_t [range]` actuals: golden mints (`a7`) /
  mints nothing (`a6`); we mint nothing in both — `a7` is a slang reject on
  both binaries, pre-existing.
* type-parameter default naming a $unit CLASS (`b1`), a $unit ENUM typedef
  (`b2`), a typedef declared AFTER the module (`b10`), two modules sharing one
  typedef (`b9`), a module that also carries a $unit enum reference (`b13`):
  law == golden.
* gates that hold: same-header `localparam type` (`b3`, the Ariane
  `acc_dispatcher` face), same-header type PARAMETER (`b4`, the
  `type_param_packed_dim` / `port_chained_type_param` face), a declared PORT of
  the name (`b5`), a value localparam of the name (`b7`), an explicit import
  (`b11`, slang-reject) and a HEADER import (`b12`), a child declaring a
  parameter (`c6`) or a typedef (`c7`) of the bound's name.
* under-mint residues: a module FUNCTION of the name (`b6`, golden mints, we
  do not), a bare-NAME override minting in the PARENT (`b14`), the interface
  holder's wire on the ELABORATED instance (`d4`); an uninstantiated module
  still mints and we match it (`d1`), a program mints nothing either side
  (`d5`).
* **ORDER when several sources feed one def** (`e1`/`e2`/`e3`): golden lists the
  def's OWN key-1 default FIRST even when its line is LATER than the parent's
  reference (`e3`: `d_t` at 5:38 before `b` at 3:41), and orders FOREIGN
  references by the instantiating module's SOURCE position (`e2`: `zb` from
  `zp_e2` at 5:42 before `ab` from `ap_e2` at 8:42). We collect foreign
  references in `defs` map order, which is DEF-NAME order, so `e2` comes out
  `ab, zb` — a wrong ORDER, never a wrong object, in a def that is unequal on
  both binaries. Listed as residue R1; no corpus row has two sources minting
  into one def.

## 3. Census (`census37.py`, comment-stripped, multi-line, both corpora)

Independent of the implementer's greps and it finds one site theirs missed —
`port_chained_type_param/dut.sv:3` (`parameter type req_t = noc_req_t`), a
same-header type parameter, GATED, and byte-confirmed unchanged. Ordered
overrides (`#(logic [...])`) were censused separately: every corpus site has a
CONSTANT range, so GATE C removes nothing live. Discovered-row sites of either
key outside the two witnesses: `type_param_packed_dim`,
`type_param_unpacked_port`, `port_chained_type_param` (same-header parameter),
`type_param_override_elem_sel` and `TypeParameterAsPortTypeWithLogicAnonymous`
(constant range), `ClassTypeParamAlias` / `class_test_53` / `riscv_instr_pkg`
(class holders), the ariane family (`SURELOG_FAIL` / `SLANG_REJECT` /
`NO_DATABASE`), `Verilator`'s `t_type_param.v` (the `Verilator` row is
`SLANG_REJECT`, no database), `cva6_equiv` (not a discovered test).

## 4. Reproduced headline numbers

* uhdm2rtlil pristine `774 / 30 / 67` both modes = the committed baselines,
  byte-identical (`ct8rows.sh` PASS on both).
* uhdm2rtlil law and law+gates `775 / 29 / 67` both modes; the whole-row diff
  is ONE row per mode, `param_type_logic_width`.
* surelog pristine `474 / 9` default, `469 / 8` testflags = the committed
  baseline.
* `param_type_logic_width` pristine head re-measured: 390 cmp lines, ONE head,
  `module_inst work@shift_reg`, golden's third net
  `logic_net (work@shift_reg.b), id:294, line:17:48` absent from ours.
  `packed_struct_array_fifo` pristine: 6446 lines, ONE head, golden's
  `logic_net (work@packed_struct_array_fifo.d_t), id:562, line:8:28`; under the
  law 6708 lines, ONE head, now on the module_inst's variables — ADVANCE ONLY,
  as predicted.
* byteverify `SELFCHECK=1` vs my own pristine workdir: `MOVERS 4 / 1608`,
  SELFCHECK `1607 / 1608`, the four predicted paths and no others.
* goldens `23 PASS / 0 FAIL` for the law and for the fixed binary;
  `SLANG_UHDM=/bin/false` → `0 PASS / 23 FAIL`.

## 5. Gates re-run by the verifier

* **Build + md5** — pristine `c8d72796d4550874084656de68f7b845` (= the main
  tree at 34b04279), law `4c10c4bae1347ce2e1e0916d64596866` (= the
  implementer's), law+gates `3401e58a790ad881cc226f32eb33d3b3`.
* **Goldens** — `23 PASS / 0 FAIL` for law and for law+gates;
  `SLANG_UHDM=/bin/false` → `0 PASS / 23 FAIL`.
* **u2r rows** — my pristine reproduces both committed baselines
  byte-identically (`ct8rows.sh` PASS ×2); law and law+gates move exactly ONE
  row per mode, `param_type_logic_width` `CMP_NOTEQUAL → CMP_EQUAL`.
* **u2r bytes** — `MOVERS 4 / 1608`, SELFCHECK `1607 / 1608`, the four
  predicted paths; law+gates produces the same four hashes as the law.
* **surelog rows** — pristine `474/9 + 469/8` = the committed baseline; law the
  same. The three whole-row differences against my own pristine are harness
  artifacts and appear on the PRISTINE side too: two `SURELOG_FAIL` details
  embedding the workdir path (`LowMemLib`, `LowMemPkg`) and `YosysOpenSparc`
  flipping `SLANG_REJECT ↔ SURELOG_FAIL` under memory pressure (my pristine run
  is the one that disagrees with the committed CSV; the law run agrees with it).
  `Earlgrey_0_1`'s dump column is empty in BOTH of my sweeps — `dump_verdict`
  (`scripts/verify_golden.py:521-537`) returns `''` on a uhdm-dump TIMEOUT, and
  the machine was running two verifier sweep pairs at once.
* **surelog bytes** — `MOVERS 5 / 960`, SELFCHECK `959 / 960`; every mover is
  the UVM family and every one is the documented 4-line class (`UINT:<line>` /
  `vpiDecompile:<line>` flipping against `0` or another line) on an order-blind
  sorted dump. POSITIVE CONTROL: the PRISTINE binary alone, re-run three times
  on `MiniAmiq/default`, gives three MORE distinct hashes
  (`c6b80691bba0`, `db386e94a31e`, `7207abd0e3c0`), none equal to its own sweep
  hash `12820cbd0f4a`. STRUCTURAL CONTROL: `0` sites of either key in the
  2.5 MB `uvm_pkg.sv` or in any UVM-family test dir, while the same greps see
  both u2r witnesses. Every UVM row is `CMP_EQUAL` with `0` cmp lines and `0`
  heads under the law (`rowheads.sh`, `measured=11 SKIP-NOFILE=1`).
* **Canaries** — `canaries.sh` surelog `ok=52 changed=0`, u2r `ok=8 changed=0`;
  `ctcan2.sh` surelog `ok=58 changed=0` PASS, u2r PASS; `canaudit.sh`
  `audited=29 UNCOVERED=0 FENCE-BREACH=0` PASS.
* **Protected databases, law vs my pristine, every OPS pin EXACT** —
  `SVSwitch 4842211c4030` (both modes), `YosysVerx 6ccda350c24a` (both),
  `Earlgrey_0_1` default `8bdf25272e08` / testflags `59d0ee6d10c3`,
  `InterfaceModPort 59a365f3ce2c` (both), `BlackParrotComplex`
  `e3e354129d5a` / `73a10e8217e5`, `YosysOldOr d68e0796d62c` (both).
* **Fence** — the four slang-fenced test names appear in 0 files of this patch
  (the integrator's four-name check reads 0/0/0/0); none of them was dispatched
  by anything here, and `canaudit.sh` reports `FENCE-BREACH=0`.
  `results/*.csv` read only.
* **Patch** — `/tmp/r11u37.verified.patch` applies to a FRESH `34b04279`
  worktree with rc=0, 0 conflict markers, and the applied production files
  byte-identical to mine.

## 6. Files

* `vgrid.sh`, `vgrid2.sh` — the golden grid (families A/B and C).
* `armcmp.sh` — per-arm pristine vs law vs golden net census.
* `census37.py` — the comment-stripped corpus census of both keys.
* `evidence/` — grid output, sweep row diffs, byteverify, canaries.
