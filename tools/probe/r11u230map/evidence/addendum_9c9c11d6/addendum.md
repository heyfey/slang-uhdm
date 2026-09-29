Both live pairs this map was briefed on landed while it ran: **pass 228** (pair B r11u228, `cd4fd02a`, 09:05: §
memberInitReducedRootFolds228, § parseViewSizeExprEval228, § sizeBitNetIsVar228 and the verifier's three
refinements) and **pass 227** (pair A r11u227, `9c9c11d6`, 09:20: § fwdPkgRefClassScopeSpan227, §
pkgPatFuncBodyLeftoverNoParent227, § newArrayPartSelStripped227, § landingSwitchReach227's six splits, the verifier's
§ fwdPkgRefConstSlotWhole227v). Re-measured without editing the sections above:

* **The reference.** The pass-227 integration sweep (at `cd4fd02a` + pass 227, read-only) equals the committed
  baselines at `9c9c11d6` cell for cell (1596 / 1742 / 4087 rows, 0 differences); all 3273 corpus `slang:` lines name
  the main tree's `build/slang-uhdm`, then `8d6b7668` (built at 09:10, before the sweep), frozen here as
  `slang-uhdm.h227`. Its gate lines: probe 0 regressions / 0 conversions / 20 changes, surelog 0 / 0 / 2, uhdm2rtlil 0
  / 0 / 0, downstream 803 / 66 / 2 / 0. (The pass-228 integration sweep was already removed from the scratch when
  this map reached it; pass 228's own census reads 0 firings on every gate database, and the pass-227 sweep moves
  only databases pass 227's laws name, below, so pass 228 moved no gate database.)
* **Byte movers against this map's base sweep** ([byteverify.txt](evidence/addendum_9c9c11d6/byteverify.txt), [probe_movers.txt](evidence/addendum_9c9c11d6/probe_movers.txt); fence-filtered mirrors, 2560 databases each, 8 fenced left out unread):
  **2 of 2560 corpus databases** (FuncStructVal d/t) and **20 of 4087 probe databases** (r11u24repro n3, n12;
  r11u26repro m6, m8, m9, m13, m15; r11u28repro a4-a7, a13, a16; r11v26repro v2, v9, v12, v13, v15, v16, v18), each
  re-analyzed (drivers/statejobs.py, analyze.py, addmerge.py; [landing.txt](evidence/addendum_9c9c11d6/landing.txt)).
* **The fail list at `9c9c11d6`: 28 row-modes / 15 tests, 634 probe cases: no row-mode and no case converted.**
  Changed: FuncStructVal d `endcol(7)` -> `file(5)`, t `endcol(10)` -> `file(9)` (the head #747 gone, the next first
  record #4782, the INSTR_PER_FETCH leftover golden locates at its read site); twenty probe cases shrink by one or two
  objects on their `fullname` first field.
* **Clusters at `9c9c11d6`: 694** (695 - 1): **gone N1096** (FuncStructVal d/t #747, pair A's named head: §
  fwdPkgRefClassScopeSpan227); **N0003 24 -> 4 probe cases** (§ pkgPatFuncBodyLeftoverNoParent227; OPEN and ground A
  in this map, not a named head of either pair); none new, none grew.
* **This map's prediction for the two pairs, audited at once.** Section 6 credited them, optimistically, with **8
  row-modes / 4 tests / 154 cases** (FuncStructVal d/t, struct_param_func_config d/t, cfg_func_width_loop d/t,
  BlackBePipeInt d/t), and **4 / 2 / 83** on the NAMED heads alone (the two uhdm2rtlil rows). **Realised: 0 row-modes,
  0 cases** (both counts). Of pair A's 19 named clusters 1 is gone (N1096) and 18 are unchanged; of pair B's 18, none
  moved. The reasons are the passes' own: pass 228 re-measured the four joint rows at its base and found every first
  record on ground A or behind a ground-A record, so it wrote its laws elsewhere (they fire on no gate database); pass
  227 reached FuncStructVal's #747 and N0003 and lists "not reached: struct_param_func_config, cfg_func_width_loop,
  BlackBePipeInt #15268 and #15272, N0131, the Earlgrey scope names, N0039". Map 14's live pairs (r11u224, r11u223) converted no
  row-mode either; the rows they were credited with converted, when at all, in the next refill whose brief led with
  them (InterfArrayBind d, pass 225). The optimistic credit is an upper bound, and so is the named one when a row
  needs both grounds' halves in the same cycle.
* **The new live pairs** (dispatched during this map; routes [routes_add.json](evidence/addendum_9c9c11d6/routes_add.json), drivers/mkroutes_add.py,
  from their briefs): **pair A r11u232** (base `9c9c11d6`; item 1: the four joint rows' A halves, now every cluster of
  FuncStructVal and struct_param_func_config after pass 228's decode; item 2: the param_assign stamps and the minted
  clone return variables; items 3-6: pass 227's and r11u229's residues, N0131, the Earlgrey scope names, N0039, N0008,
  the UVM A families) and **pair B r11u231** (base `cd4fd02a`; item 1: the UVM heads N0266, N0337, N0072; item 2:
  N0120; items 3-6: pass 228's residues, Earlgrey's ground-B families, the joint rows only where their first record is
  ground B, which none is at `9c9c11d6`). Their yield ([report_add.txt](evidence/addendum_9c9c11d6/report_add.txt), drivers/report15.py over the
  merged analysis):

| | row-modes | tests | probe cases | fail list after |
|---|---|---|---|---|
| pair A r11u232 (optimistic, 133 clusters) | 5 (FuncStructVal d/t, struct_param_func_config d/t, BlackBePipeInt d) | 2 | 114 | 23 / 13, 520 |
| pair B r11u231 (optimistic, 9 clusters) | 0 | 0 | 8 | 28 / 15, 626 |
| **both (optimistic)** | **5** | **2** | **123** | **23 / 13, 511** |
| both, NAMED heads only (A 22 + B 4) | 4 (FuncStructVal d/t, struct_param_func_config d/t: every one of their clusters is a named A head) | 2 | 50 | **24 / 13, 584** |

  cfg_func_width_loop d/t stays behind the kept call N0133 + N0487 (ModuleEmit `emitContAssigns`, ground B), which
  r11u231's brief does not name. BlackBePipeInt d clears on pair A's optimistic row credit: pinned on the DEFAULT row
  (PW_ROWS, [evidence/writers/bb_default_row.txt](evidence/writers/bb_default_row.txt)) its remaining clusters are written in
  ParamEmit (N0923 `stampParenCastWidthTs`, N1125 `makeParamTs`) or in TypeEmit `buildStructTs` from the `memberScope`
  ParamEmit `makeParamTs` passes (N2471, N0028: pass 228's reading); BlackBePipeInt t keeps the `--elabuhdm` clone
  names written by uhdm_main `elabCloneFullNameUnstored137` (N0014 N0905 N1179 N1446 N2476, ground B), which no brief
  names. **The ground-B list for the refill after r11u231, on top of both new pairs** (report_add.txt section 8):
  N0040 (InterfaceModPort, the harness), N0056 (PreprocTest, the harness), **N0133 + N0487 (cfg_func_width_loop d/t:
  2 row-modes with pair A's half)**, the LogicTypespec four (a user decision); then the deep lists (the UVM rows,
  Earlgrey, Rggen, Scr1SvTests, BlackBePipeInt t's clone names, unchanged from section 13). No row is open on ground A
  alone after r11u232 (every OPEN ground-A cluster together clears 0 row-modes on top of the pairs).
* The UVM order-blind distance and census are unchanged at `9c9c11d6` (no UVM database moved).
