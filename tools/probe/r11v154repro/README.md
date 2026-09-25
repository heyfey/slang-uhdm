# r11v154 — adversarial verification of r11u154 (the expression/parameter ground of the strict axis)

Base `b6af876c` (branch matrix-1.87). Implementer patch `r11u154` (15 laws, `R11U154_*_OFF`), evidence
`tools/probe/r11u154repro/README.md`. Verdict: **ACCEPT-WITH-FIX**. One law over-reached on legal SV:
§ varInitStrMethodArgDefNet154 rebinds a string method's argument in an INTERFACE or PROGRAM variable
initializer too, where golden keeps the elaborated `string_var`. Pristine was one `fullname` record away from
golden; the law made the walk list the definition net, so the verdict moved to `count` or `depth`. The
refinement § varInitDefNetModuleOnly154v (switch `R11V154_VIDMOD_OFF`, ExprEmit.cpp at the § token) keeps the
rebind to MODULE instances. Nothing else changes, and no corpus row or probe case moves between the implementer's
binary and the verified one.

## Binaries (frozen `chmod 555` copies before any measurement)

| binary | md5 |
|---|---|
| pristine (worktree build of `b6af876c`, system deps, `-j 2`) | `0b3b2d0a323c79f91d52be50e5bff788` (= the brief's) |
| implementer's law binary (worktree build of the r11u154 patch) | `c9e81a5c0efdfc6b4806d6f207216d27` (= the implementer's) |
| verified (r11u154 + § varInitDefNetModuleOnly154v) | `531025246789be4b1ef454192e91234b` |
| `build/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` |

cmds.txt audit: each of the three full sweeps names its own frozen binary in 3273 / 3273 slang lines.

## Reproduction of the implementer's numbers (bit-for-bit)

- Pristine sweep: every stage reads `regressions=0 conversions=0 changes=0`. Probe EQUAL 2445 / STRICT_NOTEQUAL
  1642. Downstream reads 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT. The only red is `law index STALE`,
  as the implementer reports (evidence/sweep_pristine.log).
- Law sweep with the implementer's binary: every CONVERSION and CHANGE line is identical to the implementer's
  `evidence/sweep_law_vs_baselines.txt` (evidence/sweep_impl_law.log):
  - probe: regressions=0, conversions=15, changes=18 (EQUAL 2460)
  - surelog: regressions=0, conversions=5, changes=15
  - uhdm2rtlil: regressions=0, conversions=20, changes=4
  - downstream: 803 IDENTICAL, and 0 of 871 verdicts move
- Byteverify (`SELFCHECK=1`) of the law sweep against the pristine sweep: surelog 22 / 960 movers (selfcheck
  959/960), uhdm2rtlil 28 / 1608 (1607/1608). These are the same mover sets as the implementer's.
- Record attribution: the strict comparator's full differing-record set, pristine vs law, as unique
  (field, A, B) triples (drivers `movrec` logic, evidence/mover_records_*.txt):
  - corpus movers: surelog 248 records leave and 0 enter; uhdm2rtlil 154 leave and 0 enter.
  - probe (evidence/probe_mover_records.txt): 89 leave and 1 enters. The one that enters is the leaf name in
    `r10earl29repro/a4_ctx` (fullname 12 -> 10), which moves from one wrong name to another, as the
    implementer reports.
  - The two probe CHANGEs whose first field becomes `type` (`g171_a_pos`, `gv184_i_minimal`) and the ones that
    move to `line`/`col` (`a2_scope`, `r11u1repro/grid2`) enter no record: the `type` record was already
    differing on pristine, and the fields ahead of it left.
- Implementer's 93 cases, re-judged with this verifier's own goldens: 73 go STRICT_NOTEQUAL -> STRICT_EQUAL,
  17 stay STRICT_EQUAL on both, 3 stay STRICT_NOTEQUAL (`hp/f14`, `lv/m1`, `lv/m2`: 1, 0 and 2 records
  leave, 0 enter). Every case has rc=0 and uhdm-cmp 0 lines.
- Each law's switch alone returns its cases to pristine's verdict (73 of 73), and the controls stay.
  `R11U154_OFF=1` gives pristine bytes on 93 / 93 cases.
- Canaries on the law sweep: surelog ok=38 changed=14 (exactly the attributed rows), uhdm2rtlil ok=16;
  ctcan2 PASS for both corpora.

## Fence finding (procedural, reported, not a code defect)

The implementer's census ran `verify_golden.py` over the whole corpora, fenced rows included, with the trace
wrapper standing in for the binary, and read "0 lines dropped" off the fenced rows' output. That is a dispatch
of the fenced tests outside the gate sweep. This pass re-derived the census fence-clean: `--filter` is a
negative lookahead built from `$FENCED` (794 surelog tests), with the verified binary under
`R11U154_TRACE=1` (evidence/census_firings_fenceclean.txt). It reads the same 133 firing lines, with per-law
counts equal to the implementer's (CASTREF 6, DEFPKGTS 14, GSFOLDTS 6, GSPROCPS 10, HPELEMNAME 2, HPPSBOUND 13,
LVBASEMEM 17, LVIDXREAD 13, LVSELNAME 9, MARGNAME 13, PIUNPACKED 4, PSBOUNDPATH 4, PVNESTTS 20, VARINITDEF 2).
Every one of the 50 movers is a predicted row. The predicted rows that do not move are ArrayMethodIterator,
GenForIfaceLocalparamNestedGen, GenIfIfaceParamStructField, iface_ff_genvar_partsel, iface_wholestruct_param,
struct_array_indexed_write, struct_little_endian_bit_array and struct_part_select_write. The landed code does
not depend on the breached reading. The patch and this directory spell no fenced name: drivers take `$FENCED`
from the caller's environment and refuse to run without it.

## Breaking the laws: 96 fresh cases (the table below; first line of every case names its law)

Each case was judged four ways against the v1.87 pin, on pristine, the implementer's binary and the verified
binary: uhdm-cmp lines, uhdm-strictcmp verdict, the record set, and the downstream verdict
(evidence/grid_pris_impl_verified.txt, evidence/downstream_cases_pris_vs_verified.txt).

| outcome (pristine -> implementer -> verified) | cases |
|---|---|
| STRICT_NOTEQUAL -> STRICT_EQUAL -> STRICT_EQUAL (the laws generalise) | 41 |
| STRICT_EQUAL on all three (controls) | 14 |
| **STRICT_NOTEQUAL fullname -> count/depth -> STRICT_EQUAL** (the break, fixed) | 4: `vi/f4 f6 f8 f10` |
| STRICT_NOTEQUAL on all three, 0 records enter, 0-6 leave | 9 |
| NOT_EQUAL at stage 1 on all three (pre-existing uhdm-cmp faces; the verdict is the same on all three) | 28 |

All 96 have a downstream verdict equal on pristine and verified (87 IDENTICAL, 7 EQUIVALENT, and pristine's own
`cq/r1` DIVERGENT and `lb/i10` STATUS_DIFF, which are residues below). The only non-zero rc is `he/b3` and
`lb/i5` rc=4, the same on all three binaries.

### The break: § varInitStrMethodArgDefNet154 in an interface or a program

`interface ifc; string s = "abcd"; string t = "ab"; int b = s.compare(t); endinterface` (vi/f4), and the same
with the interface passed through a port (f8), with `substr(k, k+1)` (f10), and as a `program` (f6).

- Golden binds the argument `t` to the elaborated `string_var` (`work@top.i.t`): Surelog re-elaborates an
  interface's or a program's variables.
- The law rebound `t` to the definition listing's `logic_net`, and the strict walk then lists that net: vi/f4
  reads `objects 40 vs 43`, STRICT_NOTEQUAL count; vi/f8 and vi/f10 read depth.
- Pristine differed by a single fullname record, which § builtinMethodArgNamedByPath154 clears on its own.
- Refinement § varInitDefNetModuleOnly154v: the rebind requires the owning instance body's definition to be a
  MODULE (`DefinitionKind::Module`). Under it f4, f6, f8 and f10 read STRICT_EQUAL, and the module forms stay
  STRICT_EQUAL (the implementer's `sm/s1 s2 s5 v4` and this pass's `vi/f1 f5 f7 f9`).
- `R11V154_VIDMOD_OFF=1` writes the implementer's bytes on 189 / 189 cases (93 + 96).

## Gates on the verified binary (evidence/sweep_verified.log)

| gate | result |
|---|---|
| (1) build, md5 | pristine `0b3b2d0a…` = the brief's; verified `53102524…` |
| (2) probe | regressions=0 conversions=15 changes=18; EQUAL 2460 STRICT_NOTEQUAL 1627; probe.csv byte-identical to the implementer's |
| (3) surelog / uhdm2rtlil | regressions=0; conversions 5 + 20; changes 15 + 4; uhdm2rtlil.csv byte-identical to the implementer's; surelog.csv differs only in the LowMemLib/LowMemPkg testflags detail text (the workdir path) |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, 0 of 871 verdicts move; downstream.csv byte-identical to the implementer's; the ten converted uhdm2rtlil rows all IDENTICAL |
| (5) uhdm-cmp | every row keeps its status: 480/3 + 474/3, 803/1/67 both modes; no probe case leaves judge-equal |
| (6) byteverify vs pristine | 22 / 960 + 28 / 1608 movers, the same sets as the implementer's binary (selfcheck 959/960, 1607/1608) |
| byteverify vs implementer | uhdm2rtlil 0 / 1608. surelog 6 / 960, all in the UVM order coin: MiniAmiq d/t, SeqDriver d/t and SimpleUVM t differ by 4 lines (the UINT/vpiDecompile coin); Scoreboard d differs by 92 ordered lines and 0 order-blind (evidence/uvm_coin_orderblind.txt) |
| canaries | surelog ok=38 changed=14 (the attributed rows), uhdm2rtlil ok=16; ctcan2 EXPECT_UNKNOWN=1 PASS, EXPECT_UNKNOWN=6 PASS |
| switches | per law, each case returns to pristine's verdict with its switch alone (118 converted, 71 controls: evidence/switches_verified.txt); `R11U154_OFF=1` gives pristine bytes on 189 / 189 cases |

Conversions (fresh rows, verified sweep; `results/` untouched):

    surelog:    BasicOh,default,CMP_EQUAL,,,equal
                InterfaceParamOverrideProp,{default,testflags},CMP_EQUAL,,,equal
                StringMethod,{default,testflags},CMP_EQUAL,,,equal
    uhdm2rtlil: comb_dyn_2d_packed_sel, iface_arr_struct_field_partsel, iface_cfg_mem, iface_nested_param_field,
                iface_param_2level, iface_scalar_localparam, iface_struct_field_param_width,
                iface_struct_field_partsel, jeras_tcb_gpio, mem_ff_partial_rsp: {default,testflags},CMP_EQUAL,,,equal
                (downstream: all ten IDENTICAL)
    probe:      the 15 cases of the implementer's list, each EQUAL,,equal

## Residues found by the break grids (decoded to a face, not landed)

1. `cq/r1` (§ elabCastSharesDeclRef154 grid): `assign p = SEL_W'(3)`, a cast to a localparam width assigned
   straight to an output. It reads **DIVERGENT downstream on pristine** (nohier/il/synth differ) and uhdm-cmp
   NOT_EQUAL. The laws do not change it. It is a real downstream divergence on legal SV (a bare size cast as a
   continuous-assign RHS).
2. `lb/i10` `sa[i].f[3:0] <= d` (a packed struct array element's member part-select) reads STATUS_DIFF
   downstream on pristine (Surelog READ_FAIL, slang NO_GATES). uhdm-cmp NOT_EQUAL.
3. `he/b2`: an lvalue element of an interface path (`bus.req_dly[1].adr <= x`). Golden names the element
   `work@m.bus.req_dly[1].adr.req_dly` and ends the base at the element (endcol). § hpElemSelNameIsPathSoFar154
   covers only reads.
4. `dp/l6`: the definition-listing ref_typespec of an interface port's instance (`work@top.u.t` in ours, empty
   in golden). Not a § defPkgStructParamMemberNames154 face.
5. `gf/d3`: a generate-CASE block's definition view names its members `c4.v` in golden and `work@rs.c4.v` in
   ours (12 records). § genProcFoldTsKeepsScope154 clears 4 of 16.
6. `pv/o2`: a positional modport connection. This is the implementer's sister face S6 (ModuleEmit
   emitInstance).
7. `ma/e6`: a class method's string-method argument, whose remaining record is an endcol.
8. 28 cases are NOT_EQUAL at stage 1 on pristine, mostly package-qualified or function bounds inside
   interface-path part-selects, packed struct array element paths, and nested interface array writes. They sit
   below the strict axis.

## Files

- `<grid>/<case>/dut.sv`: 96 cases, with the law in the first line. The grid-to-law map:
  - hp: hpPartSelBoundNamesBySelect154
  - he: hpElemSelNameIsPathSoFar154
  - gs: genScopeProcPsNamedByScope154
  - gf: genProcFoldTsKeepsScope154
  - ma, ms (q1, q2): builtinMethodArgNamedByPath154
  - vi (f1-f3, f5, f7, f9), ms/q3: varInitStrMethodArgDefNet154
  - vi (f4, f6, f8, f10): varInitDefNetModuleOnly154v
  - ca, cq: elabCastSharesDeclRef154
  - lx: lvIdxPathIsRead154
  - lb: lvPathBaseAtFirstMember154
  - ls: lvPathSelNamedByChain154
  - bs: lvIfacePathBitSelWhole154
  - dp: defPkgStructParamMemberNames154
  - pu: paramInitUnpackedMemberPath154
  - pp: psBoundPathFirstMember154
  - pv: portViewNestedPatTsNamed154
- `drivers/`:
  - `vc.sh <case> [bins]`: golden with the probe flags, then rc, uhdm-cmp lines and strict verdict per binary.
  - `ds.sh <bin> <out> <cases>`: the downstream verdict per case, with a private GOLDEN_CACHE.
  - `sw.sh <bin> <repro>`: the per-law switch check.
  - `probemov.py <pris wd> <law wd>`: the probe record census.
  - `tracewrap.sh`: the census stand-in.
  - `env.sh`: the tool paths. `FENCED` must be exported by the caller; `vc.sh` and `ds.sh` refuse without it.
- `evidence/`: the files named above.

### Case table (pristine | implementer | verified)

| case | law | pristine | implementer | verified |
|---|---|---|---|---|
| bs/k1 | lvIfacePathBitSelWhole154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| bs/k2 | lvIfacePathBitSelWhole154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| ca/g1 | elabCastSharesDeclRef154 | STRICT_NOTEQUAL depth | STRICT_EQUAL | STRICT_EQUAL |
| ca/g2 | elabCastSharesDeclRef154 | STRICT_NOTEQUAL depth | STRICT_EQUAL | STRICT_EQUAL |
| ca/g3 | elabCastSharesDeclRef154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| ca/g4 | elabCastSharesDeclRef154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| ca/g5 | elabCastSharesDeclRef154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| ca/g6 | elabCastSharesDeclRef154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| cq/r1 | elabCastSharesDeclRef154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| cq/r2 | elabCastSharesDeclRef154 | STRICT_NOTEQUAL depth | STRICT_EQUAL | STRICT_EQUAL |
| dp/l1 | defPkgStructParamMemberNames154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| dp/l2 | defPkgStructParamMemberNames154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| dp/l3 | defPkgStructParamMemberNames154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| dp/l4 | defPkgStructParamMemberNames154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| dp/l5 | defPkgStructParamMemberNames154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| dp/l6 | defPkgStructParamMemberNames154 | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL fullname |
| dp/l7 | defPkgStructParamMemberNames154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| dp/l8 | defPkgStructParamMemberNames154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| dp/l9 | defPkgStructParamMemberNames154 | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL line | STRICT_NOTEQUAL line |
| gf/d1 | genProcFoldTsKeepsScope154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| gf/d2 | genProcFoldTsKeepsScope154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| gf/d3 | genProcFoldTsKeepsScope154 | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL fullname |
| gs/c1 | genScopeProcPsNamedByScope154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| gs/c2 | genScopeProcPsNamedByScope154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| gs/c3 | genScopeProcPsNamedByScope154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| gs/c4 | genScopeProcPsNamedByScope154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| gs/c5 | genScopeProcPsNamedByScope154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| he/b1 | hpElemSelNameIsPathSoFar154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| he/b2 | hpElemSelNameIsPathSoFar154 | STRICT_NOTEQUAL endcol | STRICT_NOTEQUAL endcol | STRICT_NOTEQUAL endcol |
| he/b3 | hpElemSelNameIsPathSoFar154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| hp/a1 | hpPartSelBoundNamesBySelect154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| hp/a2 | hpPartSelBoundNamesBySelect154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| hp/a3 | hpPartSelBoundNamesBySelect154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| hp/a4 | hpPartSelBoundNamesBySelect154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| hp/a5 | hpPartSelBoundNamesBySelect154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| hp/a6 | hpPartSelBoundNamesBySelect154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| hp/a7 | hpPartSelBoundNamesBySelect154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| hp/a8 | hpPartSelBoundNamesBySelect154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| lb/i10 | lvPathBaseAtFirstMember154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| lb/i11 | lvPathBaseAtFirstMember154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| lb/i12 | lvPathBaseAtFirstMember154 | STRICT_NOTEQUAL endcol | STRICT_EQUAL | STRICT_EQUAL |
| lb/i1 | lvPathBaseAtFirstMember154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| lb/i2 | lvPathBaseAtFirstMember154 | STRICT_NOTEQUAL endcol | STRICT_EQUAL | STRICT_EQUAL |
| lb/i3 | lvPathBaseAtFirstMember154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| lb/i4 | lvPathBaseAtFirstMember154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| lb/i5 | lvPathBaseAtFirstMember154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| lb/i6 | lvPathBaseAtFirstMember154 | STRICT_NOTEQUAL endcol | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL fullname |
| lb/i7 | lvPathBaseAtFirstMember154 | STRICT_NOTEQUAL endcol | STRICT_EQUAL | STRICT_EQUAL |
| lb/i8 | lvPathBaseAtFirstMember154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| lb/i9 | lvPathBaseAtFirstMember154 | STRICT_NOTEQUAL endcol | STRICT_EQUAL | STRICT_EQUAL |
| ls/j1 | lvPathSelNamedByChain154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| ls/j2 | lvPathSelNamedByChain154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| ls/j3 | lvPathSelNamedByChain154 | STRICT_NOTEQUAL endcol | STRICT_EQUAL | STRICT_EQUAL |
| lx/h10 | lvIdxPathIsRead154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| lx/h1 | lvIdxPathIsRead154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| lx/h2 | lvIdxPathIsRead154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| lx/h3 | lvIdxPathIsRead154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| lx/h4 | lvIdxPathIsRead154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| lx/h5 | lvIdxPathIsRead154 | STRICT_NOTEQUAL col | STRICT_NOTEQUAL col | STRICT_NOTEQUAL col |
| lx/h6 | lvIdxPathIsRead154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| lx/h7 | lvIdxPathIsRead154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| lx/h8 | lvIdxPathIsRead154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| lx/h9 | lvIdxPathIsRead154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| ma/e1 | builtinMethodArgNamedByPath154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| ma/e2 | builtinMethodArgNamedByPath154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| ma/e3 | builtinMethodArgNamedByPath154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| ma/e4 | builtinMethodArgNamedByPath154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| ma/e5 | builtinMethodArgNamedByPath154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| ma/e6 | builtinMethodArgNamedByPath154 | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL endcol | STRICT_NOTEQUAL endcol |
| ma/e7 | builtinMethodArgNamedByPath154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| ms/q1 | builtinMethodArgNamedByPath154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| ms/q2 | builtinMethodArgNamedByPath154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| ms/q3 | varInitStrMethodArgDefNet154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| pp/n1 | psBoundPathFirstMember154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| pp/n2 | psBoundPathFirstMember154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| pp/n3 | psBoundPathFirstMember154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| pp/n4 | psBoundPathFirstMember154 | STRICT_NOTEQUAL col | STRICT_EQUAL | STRICT_EQUAL |
| pp/n5 | psBoundPathFirstMember154 | STRICT_NOTEQUAL col | STRICT_NOTEQUAL col | STRICT_NOTEQUAL col |
| pu/m1 | paramInitUnpackedMemberPath154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| pu/m2 | paramInitUnpackedMemberPath154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| pv/o1 | portViewNestedPatTsNamed154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| pv/o2 | portViewNestedPatTsNamed154 | STRICT_NOTEQUAL col | STRICT_NOTEQUAL col | STRICT_NOTEQUAL col |
| pv/o3 | portViewNestedPatTsNamed154 | STRICT_EQUAL | STRICT_EQUAL | STRICT_EQUAL |
| pv/o4 | portViewNestedPatTsNamed154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| pv/o5 | portViewNestedPatTsNamed154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| pv/o6 | portViewNestedPatTsNamed154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| vi/f10 | varInitDefNetModuleOnly154v | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL depth | STRICT_EQUAL |
| vi/f1 | varInitStrMethodArgDefNet154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| vi/f2 | varInitStrMethodArgDefNet154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| vi/f3 | varInitStrMethodArgDefNet154 | NOT_EQUAL stage1 | NOT_EQUAL stage1 | NOT_EQUAL stage1 |
| vi/f4 | varInitDefNetModuleOnly154v | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL count | STRICT_EQUAL |
| vi/f5 | varInitStrMethodArgDefNet154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| vi/f6 | varInitDefNetModuleOnly154v | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL count | STRICT_EQUAL |
| vi/f7 | varInitStrMethodArgDefNet154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
| vi/f8 | varInitDefNetModuleOnly154v | STRICT_NOTEQUAL fullname | STRICT_NOTEQUAL depth | STRICT_EQUAL |
| vi/f9 | varInitStrMethodArgDefNet154 | STRICT_NOTEQUAL fullname | STRICT_EQUAL | STRICT_EQUAL |
