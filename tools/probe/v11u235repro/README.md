# v11u235: adversarial verification of r11u235

**Base** `7d6de7c1` (branch matrix-1.87). The implementer's patch `/tmp/r11u235.patch` (md5 `734bc3a77cfdc5511b69a21327996cfc`)
applies clean on a fresh `7d6de7c1` (`git apply --check`) and, without `tests/LAWS.md`, on `6152687bb` (pass 232).
**Verdict: no break found on legal SystemVerilog or Verilog. Every headline number reproduces bit for bit.** The
production source is shipped unchanged. The verified patch fixes only the law attribution of five r11u235 cases and adds
this directory. The four slang-fenced tests are never named. Every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` through `r11u235repro/drivers/env.sh` and fails closed.

## 1. Binaries (built by the verifier, frozen `chmod 555` in `/tmp/v11u235_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pristine` | `a1764ed4564edf9e4a18ccf9a632189e` | `7d6de7c1`, system-deps cmake, `-j 2`: the brief's md5 |
| `law` | `76f31c3af119ea8abfe7942e9ecd93ba` | `7d6de7c1` + the implementer's patch: equal to the implementer's `final` |
| `l234` | `7f393917abb9286809b52f3ba4dd64e9` | `7d6de7c1` + `/tmp/r11u234_law.patch` (md5 `9d78d04f…`), include conflict kept both headers: equal to the implementer's `l234` |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's build |

Sweep `cmds.txt` audit: 3273 lines name `/tmp/v11u235_bin/law` in `/tmp/v11u235_wL`, 3273 name `/tmp/v11u235_bin/pristine`
in `/tmp/v11u235_wP`. Pristine probe databases for the byte comparison come from a second probe sweep run from the law
worktree (`/tmp/v11u235_wQ`). The probe databases embed the source path, so the two worktrees' sweeps cannot be
compared byte for byte.

## 2. Gates reproduced (`tests/sweep.sh --jobs 3`)

| stage | law sweep | matches the implementer |
|---|---|---|
| probe | regressions=0 conversions=6 changes=2, EQUAL 3460 / STRICT_NOTEQUAL 627 | yes (b10_bothtd, a5_argpos, a8_newlhs, v158_i, x09_struct, x10_enum; a6_type line(15)->line(9), v97_c9_pkganchor fullname(2)->depth(1)) |
| surelog | regressions=0 conversions=2 changes=5; default 469+11, testflags 465+9 | yes |
| uhdm2rtlil | regressions=0 conversions=0 changes=0; 801/2 per mode | yes |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; csv byte-identical to the pristine sweep and to `results/downstream_uhdm2rtlil.csv` | yes |

The fresh conversion rows are `PreprocTest,default,CMP_EQUAL,,,equal` and `PreprocTest,testflags,CMP_EQUAL,,,equal`.
The law sweep exits 0 with `law index current`. The pristine sweep exits 1 on `law index STALE` only.

* byteverify (`SELFCHECK=1`, [evidence/byteverify.txt](evidence/byteverify.txt)): surelog 11 / 960, with matching path
  sets and a selfcheck of 959/960. uhdm2rtlil 0 / 1608, selfcheck 1607/1608. probe 15 / 4087
  ([evidence/probe_movers.txt](evidence/probe_movers.txt)). All 26 movers appear in the implementer's frozen
  prediction (`r11u235repro/evidence/census/prediction_frozen.txt`), and every database it predicts moved.
* Away census (`r11u235repro/drivers/awayall.py`, [evidence/away_sweep.txt](evidence/away_sweep.txt)): **chain 0 lost /
  745 toward; flat 3 lost / 719 toward**. The 3 flat records are the unnamed `ref_typespec` under
  `uvm_enum_wrapper::m_init_map`'s `ref_var e`, which golden does not hold at that chain. They come from
  § tpTdDefaultUseSharesListing234 and match the r11u234 decode's own measurement.
* Canaries against the base's `results/`: surelog ok=47 changed=5 (BuildUVMPkg d/t, Scoreboard d, SimpleUVM d/t);
  uhdm2rtlil ok=16 changed=0. `ctcan2.sh` passes on surelog (`EXPECT_UNKNOWN=1`, ok=58) and on uhdm2rtlil
  (`EXPECT_UNKNOWN=6`, ok=2). Against the main tree's `results/` (pass 232) the surelog count is ok=45 changed=7: the two
  extra changes are FuncStructVal d/t, which pass 232 moved. That is a mismatch of baselines, not something this patch
  moves.
* First records after the pass (`r11u235repro/drivers/rowhead.sh` on the law sweep): BuildUVMPkg d #77588 `file`,
  Scoreboard d #79148 `type`, SimpleUVM d #75572 `line`, MiniAmiq d #64390 `fullname`, SeqDriver d #64346 and t #64358
  `fullname`. These are the README's records. #77588 and #79148 are the foreach loop or array typespec, and
  `MakeForeach_stmt` is only in `src/StmtEmit.cpp` (ground A).

## 3. Determinism

`r11u235repro/drivers/det.sh` (three concurrent harness runs per binary on Earlgrey_0_1 and the five UVM rows, both
modes) gives one hash per row-mode on both binaries, and each hash equals its sweep's database
([evidence/det_law.txt](evidence/det_law.txt), [evidence/det_pris.txt](evidence/det_pris.txt)). Separately, 24 direct
runs of `law` on BuildUVMPkg, in three waves of 8 concurrent runs, all exit 0 with one hash. The implementer's single
odd BuildUVMPkg-default database, which lacked one unreferenced `class_typespec this_type`, **did not recur** here. It
stays an unattributed observation.

## 4. The implementer's grids, re-run with the verifier's binaries

* The 256 cases (217 composition + 39 r11u235), both views, under pristine, law, law with `R11U235_OFF=1 R11U234_OFF=1`
  and law with `R11U235_OFF=1` ([evidence/gridall_out.txt](evidence/gridall_out.txt), 2048 lines, every exit code 0):
  - 157 case-views go STRICT_NOTEQUAL -> STRICT_EQUAL, 18 go stage 1 -> STRICT_EQUAL and 2 go stage 1 -> judge-equal.
  - **0 leave STRICT_EQUAL, 0 leave judge-equality.**
  - Both switches together write the pristine bytes on all 512 case-views. `R11U235_OFF` writes the `l234` bytes on all
    512 ([evidence/l234_out.txt](evidence/l234_out.txt)).
* Each R11U235 switch alone on the 39 cases ([evidence/gridsw_out.txt](evidence/gridsw_out.txt)) loses exactly its own
  cases and nothing else: VLOGKWSPAN 22, VLOGBYTE 2, ANCHORQUAL 6, CLSENUMMEM 8, UNITCLSAGGW 14 case-views.
* vm under `-sverilog` / `--sverilog` ([evidence/svm.txt](evidence/svm.txt), 34 case-views): the law writes the pristine
  bytes on all 34. Every case except v13 (the macro model, endline on both binaries) is STRICT_EQUAL.

## 5. The attack: 32 fresh cases (`cases/`), both views, pristine / law / switches off ([evidence/grid_fresh_sum.txt](evidence/grid_fresh_sum.txt))

Results across the 64 case-views:
* Every exit code is 0 except c03, which exits 4 identically on all four binaries (slang-uhdm's unsupported construct,
  `typedef target: ClassType`).
* Both switches off write pristine bytes on all 64.
* None leaves STRICT_EQUAL or judge-equality.
* The away census (`r11u235repro/drivers/awaycase.py`) reads **chain 0 lost** everywhere: 150 toward on the first 25,
  31 on k11/k12, 0 on the rest.
* Where the census key hides the full name inside a typespec subtree, the raw names were checked by uhdm-dump. On c05,
  golden is `p::cb::this_type`, pristine `cb::this_type` and the law `p::cb::this_type`.

| case (law) | shape | pristine | law |
|---|---|---|---|
| vk/k01 (§ vlogEnumBaseKwSpan235) | `.v`, anonymous `enum logic [3:0]` variable, always block | stage 1 | stage 1, 3 records toward |
| vk/k02-k05 | `bit [1:0][1:0]`, `logic signed`, `bit unsigned`, `byte unsigned/signed` in Verilog mode | Surelog fails (illegal in Verilog mode) | - |
| vk/k06 | enum local to a function, beside a package-free typedef | stage 1 | stage 1, toward |
| vk/k07 | package enum `logic [W-1:0]` in a `.v` | endcol | **EQUAL** |
| vk/k08 | enum built by a pasting macro, `bit` and `logic` | endcol | endcol (the macro model), 10 toward |
| vk/k09 | a comment between keyword and range; `int unsigned` and `integer` controls | endcol | **EQUAL** |
| vk/k10 | CRLF, keyword and range on two lines | endline | **EQUAL** |
| vk/k11 | anonymous enum as a packed struct member | endcol | endcol: the enum records cleared; the next is the struct member `logic [1:0] g`, which Surelog also spans at the keyword (residue 2) |
| vk/k12 | `logic [W-1:0]` enum in a module instanced with two widths | endcol | **EQUAL** |
| vk/k13 | Verilog-mode `logic [3:0] r;` / `bit` / typedef variables (control) | stage 1 | stage 1, bytes unchanged |
| ca/c01 (§ clsTdAnchorAliasQualName235) | class nested in a package class | stage 1 | bytes unchanged |
| ca/c02 | the same class name `cb` in two packages | stage 1 | stage 1, moved (toward) |
| ca/c03 | specialization typedef in a module | exit 4 on all | - |
| ca/c04 | value-parameter specialization, typedef in a second class | fullname | **EQUAL** |
| ca/c05 | `p::i_t` used by a module variable and a static call | stage 1 | stage 1, the alias name now golden's |
| ca/c06 | the `uvm_derived_callbacks` shape plus a second package | fullname | **EQUAL** |
| rs/s01 (§ clsTdClsEnumMemberShares235) | rs/r01 without builtins | stage 1 | bytes unchanged |
| rs/s02 | packed struct, enum and an alias of it in the same class | stage 1 | stage 1, 18 toward |
| rs/s03 | `$unit` classes | stage 1 | **EQUAL** |
| rs/s04 | parameterized class, `pol#(3)::rs_e` member in another class | stage 1 | judge-equal (`type`) |
| rs/s05 | module-nested class extending a package class | fullname / stage 1 (elab) | fullname / judge-equal (elab) |
| ui/w01 (§ unitClsAggTdLastWriter235) | package vector typedef, struct, package class beside a `$unit` class | fullname | fullname, later: the class variable's own `byte_t` ref (residue 3) |
| ui/w02 | packed union over a struct, two `$unit` classes, only one using the type | fullname | **EQUAL** |
| ui/w03 | class reads `p::pk_t` qualified, no file-scope import (control) | EQUAL | EQUAL, bytes unchanged |
| ui/w04 | two packages, an interface, a class extending a virtual class | stage 1 | stage 1, moved |
| ui/w05 | a `$unit` parameterized class specialized by a package struct | fullname | `file`: the type parameter location, ground of a different family |
| ui/w06 | import in one file, class in another (two-file `args`) | EQUAL | EQUAL, bytes unchanged |
| ui/w07 | `$unit` struct typedef and another class's struct typedefs (no `::` package name) | stage 1 | bytes unchanged |
| ui/w08 | vector typedef members, a function formal, two classes using different types | fullname | **EQUAL** |

Downstream (`drivers/ds.py`, both binaries): vk k06-k10 and ui w01, w02, w03 and w05 read IDENTICAL on both, and vk/k01
reads EQUIVALENT on both. No verdict moves.

## 6. Findings

1. **No production break.** No probe case, corpus row or downstream row leaves its status. No fresh case-view leaves
   equality, and no chain record moves away.
2. **Law attribution of five r11u235 cases (fixed in the verified patch, test bytes unchanged, [evidence/ed_out.txt](evidence/ed_out.txt)).**
   `cases/ui/u01`-`u04` named a law that does not exist in the source (`§ unitImportClassLastWriter235`, a draft name),
   so `tests/LAWS.md` attributed them to nothing; they now name § unitClsAggTdLastWriter235. `cases/vm/v08` (the `byte`
   face) named § vlogEnumBaseKwSpan235; it now names § vlogEnumByteBaseUnsigned235.
3. **The law index cannot see the Verilog-mode cases.** `scripts/law_index.py` attributes only `*.sv` files under
   `tools/probe`, and the cases of § vlogEnumBaseKwSpan235 and § vlogEnumByteBaseUnsigned235 must be `.v` or `.vh` roots
   to exercise the mode. `tests/LAWS.md` lists only v06 and v11 for the span law and no case for the byte law. Fixing
   this is a harness change (out of scope); the README names the law beside every case.
4. `r11u235repro/drivers/awaycase.py` and `gridcmp.py` carry no fence check. They read only case stores and grid lines
   that `case.sh` produces, and `case.sh` refuses fenced paths.

## 7. Residues (ranked)

1. Every UVM row-mode's first record is on ground A: BuildUVMPkg #77588 and Scoreboard #79148 in StmtEmit's
   `MakeForeach_stmt` branch, SimpleUVM #75572 at the § implicitNetMintNoFile131 mint, and MiniAmiq / SeqDriver #64390 /
   #64346 / #64358 in the import-clone constant. The module/type clusters of BuildUVMPkg behind them were not attempted.
2. The Verilog-mode keyword span beyond the enum base: Surelog spans a `bit` or `logic` struct member (vk/k11) at the
   keyword too. A Verilog-mode `logic [3:0] r;` module variable is stage 1 at the base (vk/k13).
3. A `$unit` class's own variable typed by a package vector typedef (ui/w01): golden `work@env::v::byte_t`, ours `byte_t`.
4. The implementer's residues stand: rs/r05 (no class-scope union typedef), ui/u07 (a class declared in a module as a
   writer), ui/u10 (an interface lists no imported struct typedef), ca/a02 (a `$unit` anchored group writes no alias),
   brief items (2b)-(2i), (4) and (7).
5. The determinism observation from the implementer's first BuildUVMPkg run is not reproduced.

## 8. Files

`cases/` (32 cases; each first line names its law), `drivers/` (grid.sh, gridsw.sh, sum.py, ds.py; they use
`r11u235repro/drivers/case.sh` and `env.sh`), `evidence/` (the grids, byteverify, the probe movers, the away census and
the determinism runs).
