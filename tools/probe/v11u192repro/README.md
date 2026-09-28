# v11u192 — adversarial verification of r11u192: every headline number reproduced; one break found and fixed (a for-generate fold nested in the right-hand side of an assignment to a whole outside net keeps its select / generate-scope name, § genForWholeLhsNestedKeep192v); verdict ACCEPT-WITH-FIX

Verifier pass of r11u192 (pair A, the expression/parameter ground). Base `a1c89c1a` (branch matrix-1.87). Worktrees
`/tmp/wt_v11u192` (the implementer's patch plus this refinement) and `/tmp/wt_v11u192pris` (pristine), system-deps
config, `-j 2`. r11u191 had not landed (no `tools/probe/r11u191dec`), so question (0) does not apply. Pass 188 (the
sister's module/type ground) landed on the main tree during this run (`6ab9f4fb`); every measurement here is at
`a1c89c1a` against that commit's `results/` baselines.

## Verdict

**ACCEPT-WITH-FIX.** r11u192's headline numbers reproduce exactly. Its eight laws hold on every shape tried except one:
§ psBoundPaOwnerName192's for-generate branch and § genForReplCountOwner192. These **break legal SV where pristine was
right**. Take a for-generate continuous assignment that writes a WHOLE net declared outside the generate block
(`assign z = {x[31:W], {W{1'b0}}};`, `assign z = x[W:0] | 32'd0;`, `assign z = {{W{1'b0}}, x[0]};`) with the fold
NESTED in the right-hand side. Golden keeps the select's name (`work@top.g[0].x`) and the generate scope's name
(`work@top.g[0]`) there. The law wrote the owner's name (`work@top`), and 34 case-modes went STRICT_EQUAL ->
STRICT_NOTEQUAL. A further 6 case-modes gained a wrong record while already failing on another face. Downstream stays
IDENTICAL on all of them: `ref_typespec` full names are not read by the plugin. The fix is
**§ genForWholeLhsNestedKeep192v** (`R11V192_WHOLELHS_OFF`, ExprEmit): the two branches decline on that shape. It moves no
corpus database, no downstream-lane database and no probe case against the implementer's binary, as predicted by a
frozen census. It turns all 40 break case-modes back to golden and keeps every conversion of the pass.

Deliverable `/tmp/r11u192.verified.patch` = r11u192's patch + the refinement + this directory + the regenerated
`tests/LAWS.md`.

## Binaries (frozen `chmod 555` in `/tmp/v11u192_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `5e6e8c2d6edf06661ab60336dad2f0cf` | worktree build of `a1c89c1a` = the main tree's `build/slang-uhdm` at the base |
| `law.bin` | `b5ff7af737f7b91618e43f0b6ebc385f` | `a1c89c1a` + `/tmp/r11u192.patch` built by me = the implementer's `law8.bin` (reproduced bit for bit) |
| `fix1..3.bin` | | refinement development steps (fix3 carries the trace; superseded) |
| `fix4.bin` | `61bb3b696db82f31c4fe73390d9638ec` | THE DELIVERED SOURCES (`/tmp/r11u192.verified.patch` applied to a fresh `a1c89c1a` rebuilds this md5) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's |

Sweeps `/tmp/v11u192_swP` (pris), `/tmp/v11u192_swL` (law), `/tmp/v11u192_swF` (fix3), `/tmp/v11u192_swG` (fix4), all
the same length. `cmds.txt` audit: swP 3273 `slang:` lines all `pris.bin`, swL 3273 all `law.bin`, swG 3273 all
`fix4.bin`.

## 1. Reproduction of r11u192's headline numbers (swP vs swL, both against `a1c89c1a`'s `results/`)

| stage | pristine swP | law swL (r11u192 claim) | reproduced |
|---|---|---|---|
| probe | reg 0 conv 0 chg 0, EQUAL 3039 / STRICT_NOTEQUAL 1048 | reg 0 conv 18 chg 5, EQUAL 3057 | yes: the same 18 conversions and 5 changes by name |
| surelog | reg 0 conv 0 chg 0 (458 + 454 CMP_EQUAL) | reg 0 conv 0 chg 2 (Earlgrey_0_1 d/t `col(102) -> col(95)`) | yes (see note) |
| uhdm2rtlil | reg 0 conv 0 chg 0 (790 + 790) | reg 0 conv 4 (ibex_icache d/t, iface_zero_width_field d/t), 792 + 792 | yes |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same, `downstream.csv` byte-identical to swP's | yes |
| corpus byte movers | | 9 of 2560 here (8 fenced skipped): Earlgrey_0_1 d/t, ibex_icache d/t, iface_zero_width_field d/t + UVM coin SeqDriver d/t, MiniAmiq t | yes (the coin draws 3 here, 5 there; each is the 4-line `UINT`/`vpiDecompile` order coin, `diff` of sorted dumps) |
| downstream-lane movers | | ibex_icache, iface_zero_width_field (of 805) | yes |
| probe movers | | 23, = `predicted_movers_192.txt` exactly (0 missed, 0 extra) | yes |
| `R11U192_OFF=1` | | pristine bytes on all 4087 probe cases (positive control: 23 move with the laws on) | yes |
| canaries | surelog ok=52 changed=0, u2r ok=16; both ctcan2 PASS | surelog ok=50 changed=2 (Earlgrey d/t), u2r ok=16 changed=0; both ctcan2 PASS | yes |
| UVM order-blind distance (`uvmdist.sh`) | MiniAmiq 7482, SeqDriver 6140, SimpleUVM 2918, Scoreboard 2293 | identical | yes |
| B/Q grid | | 42 of 48 firing case-modes convert | yes |

Note on Earlgrey_0_1 default in swL: the csv reads `differ:?` because the kernel OOM-killed that `uhdm-strictcmp`
while a build ran (dmesg: `Killed process ... (uhdm-strictcmp)`). That is a retry, not a measurement. Re-running it
alone reads `col(95)`, and the fix sweep swG reads `col(95)` on the same bytes. Record by record against pristine
(`sweeps/earlgrey_default_*.strict`): 7 records fixed, 0 new, the other 95 unchanged.

The 5 probe changes, record by record (fix4 vs pristine, `drivers/recdir.py`), all TOWARD:
- e4_ctrl: 15 fixed, 0 new.
- v4_ops: 10 fixed, 0 new.
- v5_hier: 4 fixed, 0 new. Its new first record `#322` was already wrong at pristine.
- vo: 2 fixed, 0 new.
- a8_orphan: 3 fixed, 0 new.

## 2. The break (fresh cases, 135 of them here, both views, golden from the v1.87 pin)

**Grids.** Grid `cases/K` (the owner law's contexts):
- Explicit and body imports, interface owner, three instance levels, call arguments and select indices, two-level
  for-generate, generate-scope functions and tasks, if-generate targets: all convert or move TOWARD.
- `k06_three_levels` moved AWAY on its for-generate records.

Its distinguisher, measured (all `i < 1` or `i < 2`, a top module and a child instance, both views):

| grid | target (LHS) | right-hand side | golden | law | fix4 |
|---|---|---|---|---|---|
| M (20 cases) | `z2[0]`, `z2[i]`, `z[15:0]` (a select) | bare, concat, repl, or, concat2 | owner | owner (CONVERT) | owner |
| M | `z` (whole, module port) | `x[W:0]` (the whole RHS) | owner | owner (CONVERT) | owner |
| M | `z` (whole, module port) | `{1'b0, x[W:0]}`, `{x[31:W], 1'b0}`, `x[W:0] \| 32'd0`, `{{W{1'b0}}, x[0]}` | **select / scope** | owner: **BREAK** | select / scope |
| N (15) | `s.f` (member) | concat, cond, cast, repl, bare | owner | owner | owner |
| N | `z` whole | concat, cond, cast, repl | **select / scope** | **BREAK** | select / scope |
| E, D, L | whole `z` with / without the genvar anywhere (`+ f(i)`), 1 / 2 iterations, instance depth 1-3 | nested | **select / scope** | **BREAK** | select / scope |
| E, L | `z[i]` (the genvar only on the LHS), a genvar through a block localparam | nested | owner | owner | owner |
| J (j4-j8) | whole `t` declared INSIDE the loop body (`wire`, `logic`) or an implicit net | nested | owner | owner | owner |
| H (12) | whole `z` | `s.g[W:0]` (a hier_path IS the whole RHS) / `(s.g[W:0])` | owner | owner | owner |
| H | whole `z` | `{1'b0, s.g[W:0]}`, `s.g[31:W] \| 0` | select (no new record at pristine) | a new wrong record | pristine's |

Neither the genvar, the iteration count nor the instance depth decides it. The target decides it: a written select or
member path, or a net declared in the loop body (or implicit there), takes the owning instance's name. A WHOLE outside
net keeps the select / scope name whenever the fold is not the whole right-hand side.

**§ genForWholeLhsNestedKeep192v** (ExprEmit.cpp, `R11V192_WHOLELHS_OFF`, trace name
`genForWholeLhsNestedKeep192v` on every decline) — at § psBoundPaOwnerName192's for-generate branch and at
§ genForReplCountOwner192, decline when all three hold:
- the continuous assignment's target is a simple identifier (`caLhsWholeName192v`, syntax);
- it is neither a select / member (`genCaLhsSelect22`) nor a net of the generate block or an ancestor generate block
  (`genCaLhsGenLocal23`). Both flags are ModuleEmit's, read only.
- the fold is not the whole right-hand side (`caSelIsWholeRhs192v`: the select's parent, through one hier_path, is not
  the continuous assignment). A replication count is always nested.

The refinement only restricts the two branches and allocates nothing. `R11V192_WHOLELHS_OFF=1` restores `law.bin`'s bytes on
all 200 refinement cases compared (both views).

**Downstream on the break cases** (`ds.one`, `-parse -nobuiltin -nocache -sv dut.sv`): m_whole_cat, e2, d_lv2_noi,
l5, j4, k01, qk03 and pk01 read IDENTICAL on pristine, law and fix4 alike. The break is a strict-axis break only.

## 3. The other laws, broken on fresh instances (final grid `evidence/grid_final.txt`: 165 cases x 2 views = 330 case-modes)

| | law.bin vs pristine | fix4.bin vs pristine |
|---|---|---|
| BREAK (pristine STRICT_EQUAL -> not) | **34** | **0** |
| NEWWRONG (a record right at pristine is wrong) | **6** | **0** |
| CONVERT | 199 | 201 |
| TOWARD (records fixed, 0 new) | 43 | 43 |
| uhdm-cmp line count changed | 0 | 0 |

Every conversion law.bin makes, fix4.bin keeps (join: 0 lost).

- **§ psBoundPaOwnerName192 / § procPsBoundOwner192 / § tfPsBoundOwner192** (K):
  - An explicit `import p::W` and a body `import p::*` behave like the header import (both convert).
  - Interface owner and hier-path member: TOWARD.
  - Generate-scope functions and tasks: convert.
  - Streaming and inc/dec targets, generate-scope processes: the laws do not fire; pristine bytes.
  - A program owner has a value face at pristine and does not fire.
- **§ ndaPsBoundOwner192**: net declaration assignments inside generate scopes are judge-unequal at pristine (golden
  keeps the reference, k05, k05b). The law does not fire there.
- **§ caPsSelFullVerbatim192** (V): a generate-scope instance's connection and a qualified bound both move TOWARD or
  convert.
- **§ pkgQualBoundSpanQualifier192** (Q):
  - Converts: an enum-constant pair of bounds, a parenthesized enum, a process in a for-generate, a net declaration
    assignment, a macro from an include under a subdirectory, an unpacked-array part select, an elaborated child's
    connection.
  - TOWARD: a cast, `(p::S)-1`, `p::S*p::T` and the conditional bound.
  - Macro-born qualifiers `` `PK::S `` / ``p::`NM`` / `` `RNG(p::S) ``: the span crosses buffers, `rawText` reads nothing
    and the law declines; the records stay wrong as at pristine.
  - `p ::S` with a space converts.
  - A package function's bound and a package-scoped class enum are judge-unequal at pristine.
- **§ pkgPatReadTsBindsTopTypedef192** (P):
  - Converts: a typedef from another package, the `parameter` keyword, two parameters sharing one typedef, a
    self-qualified `p::bus_t`, reads from both the package and a module.
  - Judge-unequal at pristine: a packed struct (no fire), a package importing the pattern package, a nested struct
    member.

**Wide boundary** (`drivers/bnd1.sh`, every `tools/probe/**/dut.sv` outside this directory: 10704 cases, default
view, pristine vs fix4; `evidence/boundary_*.txt`): 10460 SAME, 151 both-fail (3 symmetric segfaults among them),
93 MOVED. Of the movers:
- 29 are r11u192's own cases.
- The other 64 (`evidence/boundary_movers_*.txt`, golden-judged):
  - 17 CONVERT (r11u118 p22, r11u121 q10 and p22, r11u133 u01, r11u146 g4, r11u153v b07, r11u163 p08, r11u177v p04,
    r11u178 z01 and z07, r11u185v u04, r11v11u118 w12, x07 and x09, r11v145 x17 and x18, v11u168 x02);
  - 6 TOWARD (0 new records);
  - 41 judge-unequal at both binaries with an unchanged uhdm-cmp line count.
- 0 BREAK.

**Switch matrix** (`drivers/swm.sh`, `evidence/switch_matrix.txt`: every case here and r11u192's, both views, each
of the nine switches alone on fix4):
- `R11U192_OFF=1` writes pristine bytes on all 286 case-modes.
- A switch moves a case only where its law's trace fired (0 violations over 2574 checks). The positive control is 316
  switch-moves.
- `R11U192_OFF=1` on the full probe: pristine bytes on 4087 of 4087.

## 4. Gates of the delivered sources (fix4, sweep swG vs `a1c89c1a`'s baselines)

| stage | result |
|---|---|
| probe | reg 0, conv 18, chg 5, EQUAL 3057: probe.csv identical to swL's |
| surelog | reg 0, conv 0, chg 2 (Earlgrey_0_1 d/t `col(102) -> col(95)`) |
| uhdm2rtlil | reg 0, conv 4 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; `downstream.csv` byte-identical to pristine's |

The sweep exits 1 only for `law index STALE`, which reads STALE at `a1c89c1a` itself (main tree and pristine worktree
alike). The regenerated `tests/LAWS.md` in the patch reads current.
`/tmp/r11u192.verified.patch` applied to a fresh `a1c89c1a` worktree: `git apply` rc 0, `law index current`, the
build's md5 is `61bb3b696db82f31c4fe73390d9638ec` (= `fix4.bin`). On the new main HEAD `6ab9f4fb` (pass 188) the
source files apply cleanly and `tests/LAWS.md` conflicts. Regenerate it with `python3 scripts/law_index.py` at
integration.

CONVERSIONS (results/ untouched), fresh rows of swG:

    ibex_icache,default,CMP_EQUAL,,,equal
    ibex_icache,testflags,CMP_EQUAL,,,equal
    iface_zero_width_field,default,CMP_EQUAL,,,equal
    iface_zero_width_field,testflags,CMP_EQUAL,,,equal
    ibex_icache,IDENTICAL,OK,OK,3610,3610,,               (downstream)
    iface_zero_width_field,IDENTICAL,NO_GATES,NO_GATES,0,0,,

**Byte movers, predicted before the sweep** (`evidence/predicted_fix3.txt` and `predicted_fix4.txt`, frozen `chmod 444`):
- The refinement fires on NO probe case (full probe census with `R11U192_TRACE`).
- It fires on none of the law's corpus movers (census of Earlgrey_0_1 d/t and ibex_icache d/t). A refinement that
  only restricts two branches can move only databases those branches moved.
- Prediction: fix4 = law.bin's bytes everywhere.

Measured (`sweeps/byteverify_swG.txt`):
- **fix4 vs law:** 4 corpus movers of 2560, all UVM coin. MiniAmiq d/t and SeqDriver d are the 4-line `UINT` /
  `vpiDecompile` order coin; SimpleUVM d is 0 lines order-blind.
- **fix4 vs law, other lanes:** 0 of 805 downstream; 0 of 4087 probe.
- **fix4 vs pristine:** the six law movers (Earlgrey_0_1 d/t, ibex_icache d/t, iface_zero_width_field d/t) plus the
  coin; downstream ibex_icache and iface_zero_width_field; probe the 23.

Canaries (`evidence/canaries.txt`): surelog ok=50 changed=2 (Earlgrey d/t), uhdm2rtlil ok=16 changed=0, both ctcan2
PASS. UVM distance identical to pristine.

## 5. Residues (ranked; r11u192's own list stands, these are what this verification adds)

1. **The whole-outside-target shape itself**: fix4 keeps pristine's answer there, which is golden's. The UNDERLYING
   Surelog rule is not decoded: why an assignment to a whole outside net keeps the elaborator's re-clone (the
   select / scope parent) while a select target keeps the getValue clone. The grid pins it (M, N, E, L, D, J, H); a
   decode of NetlistElaboration's generate-scope cont_assign cloning would state it once, together with r11u192's
   unbased-unsized-literal rule, which may be the same mechanism.
2. **§ pkgQualBoundSpanQualifier192 declines in a parameter initializer** (`localparam logic [3:0] L = C[p::S:0];`).
   Golden spans the qualifier there too (qk07 record `#39`: golden 6:32-6:35, ours 6:32-6:36). The law's
   `!inParamInit` guard is conservative: a refinement candidate with its own grid.
3. **§ pkgQualBoundSpanQualifier192 declines on macro-born qualifiers** whose tokens span two buffers (qk01:
   `` `PK::S ``, ``p::`NM``). Golden spans `p::` in preprocessed columns. That is the macro model: the token mapping
   is the location code's (`setLoc` / `rawText`), shared with the sister ground.
4. qk07's `C[p::S:0]` in a module parameter initializer also shows an unlocated `logic_typespec` / range for the header
   parameter (`#111`-`#114`, file records). That is the module ground's.

## Files

- `cases/`, all firing the named law in their first line:
  - K: the owner law's contexts.
  - D, E, L, M, N, H, J: the distinguisher of § genForWholeLhsNestedKeep192v. Generated by `drivers/gen_*.py`
    (j1-j4 are hand shapes in `gen_j.py`).
  - Q: § pkgQualBoundSpanQualifier192.
  - P: § pkgPatReadTsBindsTopTypedef192.
  - V: § caPsSelFullVerbatim192.
- `drivers/`:
  - `env.sh` (pins; `$FENCED` read fail-closed from `tools/probe/r11u107repro/canaudit.sh`);
  - `grid.sh` (golden + ours + uhdm-cmp + strictcmp + trace per case and view);
  - `recdir.py` (record-level direction: fixed / new / still wrong);
  - `cmp3.py` (grid classification);
  - `swm.sh` (switch matrix; `PRISBIN` / `LAWBIN`);
  - `bnd1.sh` (the wide boundary; `PRISBIN` / `LAWBIN`);
  - `gen_*.py` (the case generators).
- `evidence/`:
  - `grid_final.txt`, `switch_matrix.txt`, `boundary_bytes.txt`, `boundary_movers_{pristine,fix4}.txt`;
  - `predicted_fix3.txt`, `predicted_fix4.txt`;
  - `sweeps/`: sweep summaries for swP, swL and swG, byteverify, probe movers, canaries, UVM distance, the Earlgrey
    records.

No fenced test is named in this directory. Every driver refuses a path that matches `$FENCED`. The byteverify mirrors
left out the 8 fenced row-mode databases. No gdb was used.
