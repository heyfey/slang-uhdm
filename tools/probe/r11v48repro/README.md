# r11v48 — adversarial verification of r11u48

Verdict: **ACCEPT-WITH-FIX.**  The implementer's two laws are right and their
headline numbers reproduce bit-for-bit, but the PACKED arm was
**pristine-RIGHT → patched-WRONG** on one legal-SV face (a module definition one
of whose instances is parameter-overridden and one of which is not).  The fix is
one argument, gated at the one call site; everything the pass bought is kept.

Binaries, both built here from scratch at `2e089d24`:

| binary | md5 |
|---|---|
| pristine | `bb429bfd6362775094b3e74909d02667` (byte-identical to the main tree) |
| implementer's patch | `9e5b571b5cf790228df692102343ce9f` (the exact md5 r11u48 reports) |
| verified patch | `adf22bb0c9085e300eec1b4a7c8cdacc` |

## 1. The four heads, re-measured at the base

Own workdir, own frozen pristine binary, every `cmds.txt` audited by binary
path, one `^LHS:` per arm.  All four md5s are the implementer's:

| row | mode | head md5 | lines |
|---|---|---|---|
| `cfg_func_width_loop` | default | `3399f2a4741e` | 8 |
| `cfg_func_width_loop` | testflags | `3399f2a4741e` | 8 |
| `packed_struct_array_fifo` | default | `8bb0ec013f02` | 8 |
| `packed_struct_array_fifo` | testflags | `9bfbaaec4670` | 8 |

The implementer's correction of TRIAGE2 is CONFIRMED against the source:
`dut.sv:31:20` is the `i` of `fwidth(i)` (col 20 with `if (` at 9–12,
`fwidth` at 13–18, `(` at 19) — a CALL ARGUMENT, not `if (cfg[i])`; and
`23:42..45` is the `int` of `fwidth`'s own formal.  For the fifo, `23:10..20` is
`ADDR_DEPTH` in `logic [ADDR_DEPTH:0] status_cnt_n`, declared
`localparam int unsigned ADDR_DEPTH` at `dut.sv:9`.

## 2. THE REGRESSION (found, fixed, gated)

`grid/vb4.sv` — the `we24` 2×2, signed `int`:

```systemverilog
module vb4sub #(parameter int P = 4) (input logic c, output logic o);
  logic [P:0] x;
  ...
module vb4 ...
  vb4sub #(.P(8)) u1 (...);   // overridden
  vb4sub          u2 (...);   // DEFAULT
```

pristine `CMP_EQUAL` → implementer's patch `CMP_NOTEQUAL`, head

```
LHS:
ref_typespec: (work@vb4.u2.x), id:180
|vpiParent:
\_constant: , id:178, line:3:10, endln:3:11
|vpiActual:
\_int_typespec: , id:179
RHS: <null>
```

Golden carries the ref on the DEFAULT instance's bound; the patch dropped it.
Cause: `paramValueSigned89`'s first line refuses a non-local parameter whose
`isOverridden()` is set, and that flag is **not per-instance** — for a definition
one of whose instances is overridden it reads true for the default instance's
bound too.  `§ boundOverriddenParamWidth24` already records this exact trap at
`src/TypeEmit.cpp` ~5453 ("we24's first uhdm-cmp failure").

Fix: `paramValueSigned89` grows `bool ovrAnsweredByCaller = false`; the packed
call site — which already stands inside `!ovrHere24()`, the per-instance test —
passes `true`.  The flag is **not** propagated into the recursion, so a
REFERENCED overridden parameter still lends no sign.  `vb4` returns to
`CMP_EQUAL` and no other arm on any grid moves.

`grid/vb17.sv` (the same 2×2 on an INTERFACE) is the *pre-existing* twin: our
default instance already carries no ref at the base, unchanged by either binary.
That one is a residue, not a regression.

## 3. Breaking the law — 76 arms on real v1.87 goldens

`grid/` (42 verifier arms) plus the implementer's own 40 (`g1–g22`, `h1–h18`;
their README says 34 — the directory holds 40).  `rungrid.sh` records both
producers' rc on every arm; **every arm rc=0 on both producers, 0 missing
databases**.  Scores, pristine → implementer → verified:

| arm | what it is | pris | impl | fixed |
|---|---|---|---|---|
| `vb4` | signed `int` 2×2, default instance | EQ | **NOTEQ** | EQ |
| `vb7` | `byte`/`shortint`/`longint`/`integer` bounds | NOTEQ | EQ | EQ |
| `vb8` | the bound on the RIGHT of the range | NOTEQ | EQ | EQ |
| `vb14` | two packed dims, signed × unsigned | NOTEQ | EQ | EQ |
| `vb16` | `int unsigned` 2×2 | NOTEQ | EQ | EQ |
| `g6`, `h2 h3 h6 h7 h8 h9 h10 h11 h12 h14` | implementer's own | NOTEQ | EQ | EQ |
| everything else (61 arms) | — | unchanged | unchanged | unchanged |

Arms that stay not-equal but whose BOUND cells move to golden: `vb12` (typedef'd
`int unsigned`, 1 cell), `vb13` (gen-block, 2 cells), `vd3` (3-hop chain),
`vd4` (enum-typed localparam).  Order-blind dump distance to golden, pristine →
fixed, never rises on any arm: `h15` 5→4, `vd3` 13→8, `vd4` 38→31, `vd1`/`vd5`/
`vd6`/`vb17` flat.  `vd4`'s cmp-log growth 8→37 is a mask cascade (RESUME §9),
not a regression — the order-blind distance falls by 7.

## 4. The producer decode, measured on golden — a narrowing

A golden-only census of **6944 cached golden databases** (`census_callarg.sh`,
`evidence/CENSUS.golden.subroutinelocal.typed.txt`) reads **5,478,819**
call-argument objects, of which **30,227 carry a typespec** — golden does type
expression objects, so "strip all" would have been wrong.

Of those, **632** are typed arguments whose actual is a `*_var` inside a
`function`/`task` chain: **542 in a return statement, 90 NOT**.  The 90 are UVM
class methods (`uvm_string_to_severity(sev)` under `if`/`foreach` in
`uvm_component::m_set_cl_sev`, `uvm_hdl_check_path(p_)` in
`uvm_reg_mem_hdl_paths_seq::check_mem`, …), in `CoresSweRV`, `CoresSweRVMP` and
`Opentitan` — all three `SLANG_REJECT`/`SURELOG_FAIL`, so we build no database
there and the guard cannot reach them.  And `grid/va1.sv` shows the converse:
a package-function body local passed in the RETURN expression that golden leaves
**bare** (it has a loop-assigned value, so `reduceExpr` replaces it).

So the implementer's "the split is the return-expression window and nothing
else" is a statement about the cells OUR emitter can reach, not the producer's
rule; the true discriminator is whether the reference still has no value when
`ExprEval::EvalFunc` runs.  In class-method context we emit no stamp at all
(`va3`, `g12`, both binaries, both matching golden), so the window is safe here
— but it is the residue to reopen if any of those three rows ever compiles.

## 5. Census, a-priori prediction, movers

`predict48v.py` re-runs every arm of my own pristine workdirs with the verified
binary twice — `R11U48_OFF=1` (must be byte-identical: the positive control that
the instrument is wired) and `R11U48_DBG=1` (names every changed cell).

| corpus | arms | OFF byte-SAME | NOT-SAME | cells named |
|---|---|---|---|---|
| uhdm2rtlil | 1608 | **1608** | 0 | **6** |
| surelog | 960 | 955 | 5 | **0** |

The 6 u2r cells name, a priori, exactly `cfg_func_width_loop` (2) and
`packed_struct_array_fifo` (1), both modes — and nothing else.  The Surelog zero
is a MEASURED zero: the same instrument, the same invocation path, printed 6
lines on u2r.

The 5 surelog NOT-SAME are `MiniAmiq` ×2, `SeqDriver` ×2, `Scoreboard`/default.
Three further runs of the PRISTINE binary ALONE on each of those arms give four
distinct hashes for MiniAmiq in both modes and a two-way flip for SeqDriver and
Scoreboard — pristine nondeterminism, not the patch.

`byteverify.sh SELFCHECK=1`, verified vs my own pristine workdir:
u2r **MOVERS 4 / 1608**, SELFCHECK 1607/1608 — the four predicted databases and
nothing else.

**Attribution, order-blind against each row's own golden** (sorted dumps, paths
normalised): `cfg_func_width_loop` 134 → 120, `packed_struct_array_fifo`
216 → 208, identical in both modes.  Every changed dump line is a REMOVAL, zero
additions, and the removals are exactly the law's:
`ref_typespec (q::maxw::i)` ×2 with its `int_typespec` and `vpiTypespec`/
`vpiParent`/`vpiActual`/`vpiFullName` lines, and the fifo's single
`ref_typespec (work@packed_struct_array_fifo.status_cnt_n)` set.
**TO-GOLDEN 22 / AWAY-GOLDEN 0 / MOVED-WRONG 0.**

## 6. Gates (verified binary)

* pristine md5 `bb429bfd6362775094b3e74909d02667` = the main tree at `2e089d24`;
* goldens **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**;
* uhdm2rtlil **783 / 21 / 67 both modes** (pristine 782/22/67 both modes,
  re-measured here); whole-row gate: exactly **1 differing row per mode**, the
  conversion;
* surelog **474/9 + 469/8** pristine, re-measured here; see §7 for the patched
  columns;
* canaries u2r `ok=8 changed=0`; `ctcan2` PASS; `canaudit`
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`;
* `results/*.csv` untouched (`git diff -- results/` is empty; the patch names
  only `src/ExprEmit.cpp`, `src/TypeEmit.cpp` and the two probe dirs);
* the four fenced names appear in 0 hunks;
* `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `ct8rows.sh`, `canaudit.sh`,
  `rowheads.sh` in `r11u48repro/` are byte-identical to the standing generation
  (no instrument tampering).

## 7. Residues (ranked)

* **R0 — `cfg_func_width_loop`'s next head** is r11u34's own R0: golden
  `logic_typespec (q::mask_t)` behind `sub`'s parameter `M`, with a folded
  `0 : INT 2` range, against our `mask_t` with an unfolded bound.  One test.
* **R1 — the class-method window.**  90 golden-typed subroutine-local call
  arguments sit outside any return statement (UVM `if`/`foreach` bodies).  No
  row reaches them today; if `CoresSweRV`/`Opentitan` ever compile, the guard's
  package-return window is the wrong shape for them.
* **R2 — `va1`: a return-expression body local golden leaves BARE.**  We stamp
  it in both binaries.  The unencoded half of the model — "does the reference
  still have no value when `EvalFunc` runs" — which is also r11u48's own R3
  (`g3`).  No corpus row.
* **R3 — the folded bound's WIDTH for a `$unit`-scope / IMPORTED package
  localparam** (`h17`, `h18`, `vd1`): golden folds at the declared width 32, we
  fold at 64, signed and unsigned alike.  No corpus row.
* **R4 — a PACKAGE-SCOPE typedef's folded bound carries no typespec at all in
  ours** (`vd6`): golden stamps `int_typespec` at size 32 on BOTH the `int` and
  the `int unsigned` package localparam there (the located-typespec producer,
  not the signedness one), we emit a bare 64-bit constant.  No corpus row.
* **R5 — the interface twin of `we24`** (`vb17`): the DEFAULT instance of an
  interface whose other instance is overridden already loses its bound ref at
  the base.  Pre-existing; the module twin is what §2 restored.

## 8. Re-running this

```bash
GDIR=<repo>/tools/probe/r11v48repro/grid SLB=<binary> OUT=<scratch> \
  FC=<fcarg48> RB=<rbnd48> bash rungrid.sh
python3 predict48v.py {uhdm2rtlil|surelog} <pristine workdir> <binary> <out.tsv> <scratch>
python3 abcmp48v.py  {uhdm2rtlil|surelog} <pristine workdir> <binA> <binB> <scratch>
OUT=<file> bash census_callarg.sh
```

`fcarg48` / `rbnd48` are the implementer's listers in
`tools/probe/r11u48repro/`; `rungrid.sh` here is the verifier's own copy with
its own defaults and no path hard-coded outside this pass's scratch.
