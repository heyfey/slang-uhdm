# r11u119 — the span ground: seven downstream rows become IDENTICAL

**Seven of the nine targeted downstream rows convert EQUIVALENT → IDENTICAL.**
They are typedef_package, TypedefWithParameter, hier_undriven_port,
param_type_logic_width, rp32_r5p_alu, mriscv_bind_sva and cdc_static_basic.
ibex_controller and type_param_override_elem_sel stay EQUIVALENT. Each is decoded
below (R1, R2); neither can be fixed inside this pass's surface.

* Downstream, 871 rows:
  * baseline: 781 IDENTICAL / 19 EQUIVALENT / 5 DIVERGENT / 66 SLANG_REJECT;
  * this pass: **787 / 13 / 5 / 66**.
* No row leaves IDENTICAL. gen_test7 reads EQUIVALENT in BOTH the pristine and
  the law sweep. Its slang.uhdm is byte-identical between the two binaries. The
  verdict depends on how long the workdir path is (see "Environment").
* uhdm-cmp: every corpus row keeps its status, and all 2833 probe arms are EQUAL.
* `results/` was NOT edited. The fresh downstream rows are quoted in Q6.

Base `849800d1`. Pins: slang `7d61e0ad1`, Surelog v1.87 (`0445655e`, UHDM
`c7562484`), uhdm2rtlil `ddef9ffd` with its own Surelog v1.87-5.

| binary | md5 | what |
|---|---|---|
| pristine | `ac66a3d985fbeb31fd157e4e3b06b11e` | own worktree at `849800d1`, `-j 2`; equals the main tree's binary |
| **LAW** | `7aa72216d59606d977676dfb22f3973e` | this patch, `-j 2`. A comment-only edit after the sweep was rebuilt and kept this md5 |

**Surface.** The patch touches `src/ModuleEmit.cpp`, `src/UhdmExporter.cpp` and
`tools/probe/r11u119repro/`. It does not touch the header or the sister pass's
files (ExprEmit.cpp, EmitHelpers.h, StmtEmit.cpp, ParamEmit.cpp). It does not
touch TypeEmit.cpp or TaskFuncEmit.cpp either: no face needed them.

**Switches.** Each law can be dropped alone:

* `R11U119_OFF` drops everything.
* `R11U119_SCOPEDSPAN_OFF` drops L1.
* `R11U119_ALIASGATE_OFF` drops L1b.
* `R11U119_IMPLFILE_OFF` drops L2.
* `R11U119_NUMLIT_OFF` drops L3.
* `R11U119_REALATTR_OFF` drops L4.

`evidence/DROPS119.txt` measures this over all 78 grid arms:

* `R11U119_OFF=1` writes the PRISTINE bytes on every arm (78/78 `cmp`-equal;
  the pristine binary is self-stable on 78/78).
* Each switch reverts exactly its own family: SCOPEDSPAN 25 arms (all g1),
  ALIASGATE 1 (g1 b01), IMPLFILE 8 (g2), NUMLIT 10 (g3), REALATTR 3 (g4).

## Instruments (all in this directory)

* `locdump.cpp`. Build with `g++ -O2 -std=c++17 locdump.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o locdump`.
  * It prints one row per UHDM object: `type(name) <VpiFile basename|-> l.c-el.ec [val=VpiValue] <- parent chain`.
  * Rows are sorted, so two databases diff order-blind.
  * uhdm-dump prints no VpiFile except on module_inst, and no raw VpiValue. Those two fields are exactly what `get_src_attribute` reads (module.cpp:3548: basename of VpiFile + `line.col-endline.endcol`, and `""` when VpiFile is empty) and what the attribute import reads.
* `grid119.sh <root> <out>` scores every `dut.sv` arm:
  * golden: the pinned v1.87 with the probe flags;
  * ours: `--single-unit --nobuiltin`;
  * `SPANDIFF`: the number of locdump rows on one side only;
  * `CMP`: uhdm-cmp lines;
  * both rc's;
  * with `DS=1`, the downstream verdict from `downstream_uhdm2rtlil.one` (uhdm2rtlil's own Surelog + `-DSYNTHESIS`).
* `sdb119.py <re>`: the Surelog-lane golden for a downstream row.
* `cen119.py <wd> <out.tsv> [re]` is the census, from PRISTINE databases, against the golden of each row. It works on the downstream workdir or on a corpus workdir. Faces:
  * `IMPL`: we stamp a file where golden has none;
  * `POPNET`: a definition net only we list;
  * `DECLEND`: a var/net whose end differs;
  * `COLS`: same object, same line, other columns;
  * `REAL`: the attribute's REAL text differs;
  * `OTHER`.
* `pred119.py <census.tsv> <wd> [corpus]` predicts movers a priori:
  * census faces IMPL/POPNET/DECLEND/REAL;
  * plus every row with an object on a source line where the OLD and NEW number-fold rules disagree. Both rules are re-implemented in Python.
* `dircell119.py <golden> <pristine> <law>` checks direction per object key (type(name) + parent chain). `BETTER` means the key's cell multiset moved toward golden. `WORSE` means it moved away.
* `drops119.sh`: the switch table above.

## Q1. The nine heads at 849800d1 (`evidence/HEADS119.txt`, `evidence/CELLS119.txt`)

All nine read uhdm-cmp 0 lines and downstream EQUIVALENT with the pristine
build (`evidence/nine_pristine.csv`). The RTLIL head is the `_nohier.il` diff
(surelog lane `<`, slang lane `>`), traced to the object each line comes from:

| row | nohier head | object / field (golden vs ours) |
|---|---|---|
| typedef_package | `dut.sv:11.26-11.35` vs `11.26-11.27` (wire `a` + its process), `12.26-12.42` vs `12.26-12.32` | elaborated `logic_var work@top.a` `line:11:26, endln:11:35` vs `endln:11:27`; `enum_var b_enum` `endln:12:42` vs `12:32` |
| TypedefWithParameter | `dut.sv:7.17-7.26` vs `7.17-7.18` (×2) | `logic_var work@top.w` `endln:7:26` vs `7:18` |
| hier_undriven_port | extra `attribute \src "dut.sv:17.16-17.18"` on `wire \b2` | definition `logic_net b2`: golden VpiFile EMPTY, ours `dut.sv` (dump text identical; only locdump shows it) |
| param_type_logic_width | extra `src "dut.sv:17.48-17.49"` on `wire \b` of `shift_reg` | definition `logic_net b` (the `$bits(b)` late-binding wire): golden no file |
| mriscv_bind_sva | 5 extra `src` lines (`mriscvcore.v:130.15-130.23` rdw_rsrn, `204.16` enable_pc, `223.16` done_exec, `231.18` enable_exec, `232.22` enable_exec_mem) in both nohier and il | 5 definition implicit nets (port connections), golden no file |
| rp32_r5p_alu | `r5p_alu.sv:103.7-103.75` vs `103.7-103.71` (the `default:` case) | `case_item` and `begin` `103.7-103.75` vs `…103.71`; the line is `default: … mux_op2 = 'x     ; end` |
| cdc_static_basic | `attribute \real_attr "1.5"` vs `"1.500000"` | `attribute real_attr` VpiValue `REAL:1.5` vs `REAL:1.500000` (uhdm-dump prints both as `REAL:1.500000`) |
| ibex_controller | 34 lines: `$and`/`$ne` cells and src one LINE early (`194.28-194.61` vs `193.28-193.61`, lines 189-207) | every object on source lines 189-207; the golden positions are +1 |
| type_param_override_elem_sel | 6 non-src lines: `module \child$typaram_2_1_1` vs `_1_1_1`, `wire width 4 input 1 \rt_i` vs `width 2`, `A_WIDTH 4` vs `2` | not a span: see R2 |

## Q2. Decode per family

**F1, declarator span** (typedef_package, TypedefWithParameter).

* **Plugin read.** `get_src_attribute` reads the var span for the wire and for
  the init process.
* **Producer.** In `CompileHelper::compileDataDeclaration`
  (`src/DesignCompile/CompileHelper.cpp:2380-2398`), `unpackedDimension =
  fC->Sibling(signal)`. When there are no dimensions, that sibling is the
  INITIALIZER. elabSignal then locates any object still at line 0 from the name
  to that node: `populateCoreMembers(id, unpackedDimension, obj)`
  (`NetlistElaboration.cpp:2757-2762`). So the declarator is spanned.
* **Measured rule (grid g1, 50 arms).** The WRITTEN form decides.
  * A **package-qualified** type (`pkg::t a = …`) spans the declarator. Arms:
    a01 a02 a08 a10 a11 a13 a18 a19 a21 a22 a24 b04 b06 b08-b12 c_scoped_*.
    This holds for logic, bit, int and enum typedefs, struct nets and struct
    vars, children, two declarators, and multi-line inits.
  * A wildcard-**import**, local or `$unit` typedef keeps the NAME: a03 a15 b01
    b02 b03 b05 c_import_*.
* **Our site.** The elaborated signal loop in ModuleEmit.cpp (~13920).
  * It already stretched plain-typed and `realVar` vars.
  * It also stretched an alias-of-alias, whatever the written form. b01
    (`import pkg::*; v8_t a = …`) refutes that: golden spans the name.
  * The struct_var and struct_net roads (~14160 and ~14290) keyed on "typedef in
    a package". c_import_structvar_pat refutes that key.

**F2, implicit nets have no file** (hier_undriven_port, param_type_logic_width, mriscv_bind_sva).

* **Producer.** `UhdmWriter::lateBinding` mints the net for a reference that
  finds nothing (`UhdmWriter.cpp:3987-4005`). It copies only the reference's
  four line/column fields. VpiFile is never set.
* **Our site.** § vpiFileOnEveryLocated117 (`setLoc`) stamps a file on every
  located object, these nets included.
* **Grid g2, 10 arms.** The definition net of every road carries no file in
  golden (i01-i08). The ELABORATED twin keeps its file:
  * hier_undriven_port's `inst.b2`;
  * i07 gen_scope;
  * Scr1SvTests' `i_top.SCR1_MEM_WIDTH_WORD` (measured in the corpus).
  The elaborated nets come from NetlistElaboration, not from lateBinding.

**F3, number-literal whitespace fold** (rp32_r5p_alu).

* **Producer.** The pp listener re-emits every INTEGRAL_NUMBER token with its
  spaces squeezed out: all spaces but a final one
  (`SV3_1aPpTreeShapeListener.cpp:144-172`).
* **Which text is one token is decided by the pp LEXER**
  (`grammar/SV3_1aPpLexer.g4:190-330`):
  * `Unsigned_number: Decimal_digit ('_' | Decimal_digit | ' ')*` swallows the
    trailing spaces of a PLAIN decimal, in EVERY file.
  * Based values run over `' '` too.
  * `'x` is a Special plus an identifier. It is NOT a number, so it folds nothing.
  * POUND_DELAY `'#' WS* [0-9] [0-9_.]*` and `Fixed_point_number` keep their
    spacing.
* **Our old fold** (`UhdmExporter::numLitWsShift`) had four faults:
  * it folded `'x`/`'z` (it treated the tick as a base);
  * it missed `'h`/`'o` bases (its scan stopped at a base letter that is not a
    hex digit);
  * it folded plain decimals only "in files with a directive". That was a proxy
    for the POUND_DELAY exclusion: fsm's `#1  IDLE`;
  * it missed the size-to-base space in `8 'hA5`.
* rp32's `mux_op2 = 'x     ; end` was folded by 4, which cut `end` short.

**F4, attribute REAL text** (cdc_static_basic).

* **Producer.** The attribute value is the Reduce::No constant's VpiValue
  (`CompileHelper.cpp:4790-4794`). A real literal's constant is
  `"REAL:" + SymName` (`CompileExpression.cpp:569-574`), i.e. the source text.
* **Ours.** It printed the value with `%f`.

**ibex_controller** is decoded in R1 and **type_param_override_elem_sel** in R2.

## Q3. The grid (`grid/`, 78 arms; `evidence/GRID119.txt`)

Every arm is scored on the locdump rows (file + four span fields + value)
against the pinned v1.87, and by downstream verdict with uhdm2rtlil's
Surelog. Golden rc and our rc are 0 on all 78 arms.

* **g1** (50 arms), declarator span: shapes {logic/bit/int/enum/struct-net/struct-var typedef, alias-of-alias, pkg-param-sized, signed} × written form {pkg::, import, local, $unit} × homes {top, child ×1/×2, generate, interface} × initializers {literal, expr, concat, pattern, fill, multi-line, two declarators, unpacked dims}.
* **g2** (10 arms), implicit nets: port-connection, assign LHS, gate output, `$bits(b)` in a type-parameter override, child ×2, generate, Verilog-style, ordered connection, explicit-wire control.
* **g3** (15 arms), fold: `'x 'z 'X '0 '1 0 8'hFF 'hFF 4'b10 8'h␣A5 8␣'hA5 12␣␣-1 'sd3`, in a file with and without a directive; `#1␣␣`; case default; real; index; macro arguments; comments and strings; multi-line block comment; identifier digits; parameter ports.
* **g4** (3 arms), real attributes: on a net, a reg and a port.

| | IDENTICAL | EQUIVALENT | DIVERGENT |
|---|---|---|---|
| pristine | 34 | 42 | 2 |
| **law** | **68** | 8 | 2 |

* 42 arms moved. All of them moved toward golden (SPANDIFF down or equal, downstream up).
* No arm got worse. CMP is unchanged on every arm (spans are judge-invisible).
* The 10 non-IDENTICAL arms left all carry a judge-visible structural difference:
  * a09, a14, a18 and the struct c_* arms: CMP>0 (struct_net vs struct_var class, etc.);
  * a23, see R4.

## Q4. The laws

* **L1 § scopedPkgTypeDeclSpan119** (`ModuleEmit.cpp:604` `scopedDeclSpan119`;
  sites at the var road ~13935, the struct_var road ~14160 and the struct_net
  road ~14290).
  * **Rule.** An elaborated signal whose type is WRITTEN package-qualified, and
    that has an initializer and no unpacked dimensions, spans the declarator.
  * **Scope.** Ports are excluded.
  * **L1b** (switch ALIASGATE). The alias-of-alias clause of the var road holds
    only for the qualified written form.
* **L2 § implicitNetNoFile119** (`ModuleEmit.cpp:554`).
  * **What is recorded.** The definition-view nets of these roads:
    * slang-implicit nets (module and interface definition loops);
    * interface connection-site nets (scalar and array);
    * cast-pattern key wires;
    * the late-binding mints (hoisted names, `$unit` enum constants,
      type-parameter expressions).
  * **When the file is cleared.** VpiFile is cleared LAST, in `exportDesign`, so
    no later `setLoc` re-stamps it. It is cleared only when the parent is a
    definition instance, i.e. an unnamed module_inst, interface_inst or program.
  * **The implicitNetMap wires are NOT touched.** Their mint sites are in
    ExprEmit/StmtEmit. A trial arm that cleared them from the map was REFUTED:
    SimpleUVM's hoisted `top` keeps `uvm_component.svh` in golden. The arm was
    dropped before the final sweep (see R3).
* **L3 § ppIntegralNumberFold119** (`UhdmExporter.cpp:10409`, `ppFold119Line`).
  * **What it does.** A per-buffer re-implementation of the pp lexer's
    INTEGRAL_NUMBER tokenization. It skips identifiers, strings, comments
    (including block comments across lines), escaped identifiers, `define
    bodies, macro-call argument lists and POUND_DELAY / Fixed_point tokens.
    Every dropped space shifts later columns by -1.
  * **What it leaves alone.** The run between a base letter and its value
    (`8'h A5`). That run is already taken off the spans that CONTAIN the literal,
    site by site, by `basedLiteralSpaceCount` (EmitHelpers.h:652, in the sister
    ground). Folding it here would count it twice (measured: `8'h A5 | b`
    constant `11.15-11.19` against golden `11.20`). See R5.
* **L4 § attrRealRawText119** (`ModuleEmit.cpp:4929`). An attribute's
  real-literal value is `REAL:` + the source text.

## Q5. Census by name, from pristine databases, with a positive control

* **Positive control.** `cen119.py` on the seven convertible targets plus
  1DUnpackedArray, pristine databases:
  * typedef_package: `DECLEND=2 COLS=1`;
  * TypedefWithParameter: `DECLEND=1`;
  * hier_undriven_port: `IMPL=1`;
  * param_type_logic_width: `IMPL=1`;
  * mriscv_bind_sva: `IMPL=47`;
  * rp32_r5p_alu: `COLS=3`;
  * cdc_static_basic: `REAL=1`;
  * 1DUnpackedArray: no face (the negative control).
* **Whole census** (`evidence/CENSUS_*.tsv`). The a-priori predictions
  (`pred119.py`, `evidence/PREDICTED_*.txt`) are:
  * downstream: 79 rows;
  * uhdm2rtlil corpus: 154 row-modes;
  * surelog corpus: 152 row-modes.
* **The predictor over-predicts by design:**
  * COLS/IMPL faces the laws do not cover;
  * the 4-column slack of the L3 line test.
* **Actual movers** (byteverify, below) are a SUBSET of the prediction in all
  three workdirs: **0 unpredicted movers.**

## Q6. Gates

Run from the worktree, with SLANG_UHDM exported and frozen (`chmod 555` copies).
Every corpus `cmds.txt` names the law binary: 1531 surelog and 1742 uhdm2rtlil,
by path. See `evidence/GATES119.txt`.

1. **Build.** The pristine build equals the main tree's binary (`ac66a3d985fb`). The law build is `7aa72216d596`.
2. **Probe.** `tests/sweep.sh --corpus probe`: **EQUAL=2833 of 2833** (pristine and law).
3. **Corpora.** Surelog 480/3 default and 474/3 testflags; uhdm2rtlil 803/1/67 in both modes. `regressions=0 conversions=0 changes=0` against both `results/golden_*.csv` and the pristine sweep.
4. **Downstream.** DIVERGENT=5, EQUIVALENT=13, **IDENTICAL=787**, SLANG_REJECT=66.
   * The fresh rows:
     ```
     typedef_package,IDENTICAL,NO_GATES,NO_GATES,0,0,,
     TypedefWithParameter,IDENTICAL,NO_GATES,NO_GATES,0,0,,
     hier_undriven_port,IDENTICAL,NO_GATES,NO_GATES,0,0,,
     param_type_logic_width,IDENTICAL,NO_GATES,NO_GATES,0,0,,
     rp32_r5p_alu,IDENTICAL,OK,OK,1332,1332,,
     mriscv_bind_sva,IDENTICAL,NO_GATES,NO_GATES,0,0,,
     cdc_static_basic,IDENTICAL,OK,OK,4,4,,
     ibex_controller,EQUIVALENT,OK,OK,565,565,nohier il,…PASSED…
     type_param_override_elem_sel,EQUIVALENT,OK,OK,3,3,nohier,…PASSED…
     ```
   * No row left IDENTICAL (`evidence/DOWNSTREAM_VERDICTS.txt`). The sweep exits
     1 only on gen_test7, which is environment.
5. **uhdm-cmp** stays at 0 lines on all nine rows, and on every grid arm whose count was 0.
6. **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`, same-length workdirs):

   | workdir | paths | SELFCHECK flagged | movers |
   |---|---|---|---|
   | surelog | 960 | 959/960 | 92 |
   | uhdm2rtlil | 1608 | 1607/1608 | 86 |
   | downstream | 805 | 804/805 | 43 |

   * Every mover was predicted (Q5).
   * Direction per object key (`evidence/DIRECTION_*.txt`): **WORSE=0 on all 221 movers.**
   * These movers read BETTER=0 WORSE=0 (neutral):
     * NestedPatternPassedAsPort (downstream, and u2r in both modes) and
       Inverter (surelog, both modes). Each is a definition net only WE list: a
       population extra golden does not have. L2 clears its file.
     * MiniAmiq (both modes), the known UVM `UINT` value coin.
   * The UVM family SeqDriver/SimpleUVM move BETTER (+136/+137 keys). So does
     Earlgrey_0_1 (L3: `{32'h0  , 1'b1}`).
7. **Canaries** (`canaries.sh`, `ctcan2.sh`). Status column: no canary moved.
   * The dump column differs from the COMMITTED baseline on 391 surelog and 1064
     u2r row-modes. That is true for the PRISTINE sweep too, so it is
     environment.
   * Pristine against law, the dump column moves on exactly one row-mode:
     Earlgrey_0_1/default (blank vs `differ`). That is the known Earlgrey
     dump-column draw.

**Environment: gen_test7.**

* Its slang.uhdm is byte-identical between pristine and law (`93600fca9216`).
* uhdm2rtlil's pointer-keyed maps order two `update` lines by address, and the
  address depends on the database PATH.
* With a workdir the same length as the baseline's (`/tmp/ds_r119`), both binaries read IDENTICAL.
* With this pass's workdir length, both read EQUIVALENT: pristine sweep, law sweep, and `/tmp/r11u119_wdX/downstream`.

## Residues, ranked

* **R1, ibex_controller: needs a harness change to know about `-filterprotected`** (34 lines, EQUIVALENT).
  * **The producer.** Surelog's `-filterprotected` strips
    `translate_off`/`translate_on` regions
    (`SV3_1aPpTreeShapeListener::enterComment`, :78-140). On `translate_on` it
    calls `addLineFiller` even when the region sits inside an INACTIVE branch.
    Here that is ibex_controller.sv:171-183, `ifndef SYNTHESIS` under
    `-DSYNTHESIS`. The inactive branch already filled its lines, so the pp output
    gains one line. Every position after it is +1 until the next macro expansion
    re-syncs the line map (the `ASSERT` at :208).
  * **Measured.** Probe `b0` reproduces it with and without the flag: the same
    source gives `16.14` without it and `17.14` with it. v1.87 and the
    uhdm2rtlil Surelog agree (`194.10-194.61`).
  * **Why this pass cannot fix it.** `verify_golden.translate` lists
    `-filterprotected` as IRRELEVANT (`scripts/verify_golden.py:301`), so the
    slang lane never learns the flag. slang-uhdm also has no option to receive
    it. Applying the shift unconditionally would move every no-flag golden away.
  * **The fix.** A `--filterprotected` exporter option plus a translate entry.
    `scripts/` is outside this pass's surface.
* **R2, type_param_override_elem_sel: not a span.** It is the type-parameter
  instance view.
  * Golden's `work@dut.u` vpiParameter list holds the DEF's `type_parameter
    work@child.rt_t` (17:21-17:25), shared.
  * Ours mints a fresh unlocated `work@dut.u.rt_t`. Its `packed_array_typespec`
    (17:31-17:47) range operand binds differently.
  * The plugin's `type_param_signature` / `get_width` (uhdm2rtlil.cpp:2922-2945)
    then sizes `rt_i` at 4 bits from golden's database and at 2 bits from ours.
    Both are wrong: the true width is 8. The il and synth outputs agree, so only
    the nohier RTLIL differs.
  * Owner: the type-parameter elaboration. That is `rebindElabPortTypeParam110`
    and `rebindTypeParamElem107` in UhdmExporter.cpp, and the ParamEmit minting.
    It is a structural change, not a span law.
* **R3, the implicitNetMap wires** (ExprEmit.cpp:9951 assertion formals,
  :10042 function-declaration typespec, :20356 block localparam/foreach, :36058;
  StmtEmit.cpp:2812 block label; ExprEmit.cpp:14513 `.v` hidden type).
  * They still carry a file. Golden has none on mriscv_bind_sva's `inp0`,
    `inp1`, `num`, `opcode`, `state` (5 definition nets; the row is IDENTICAL
    anyway) and on SeqDriver's hoisted UVM names.
  * Golden keeps a file on SimpleUVM's `top`. So a blanket clear is refuted. The
    discriminator (UhdmWriter lateBinding vs NetlistElaboration `bind_net_`) is
    for the sister ground to decode at the mint sites.
* **R4, grid a23 (`pkg::v8_t a = 8'h3;`, where v8_t is an alias of an alias): DIVERGENT with uhdm-cmp EQUAL.**
  * The plugin builds `wire \a` at 1 bit (`init 1'1`, wiretype `\v8_t`); golden builds 8 bits (`\pkg::v8_t`).
  * It is judge-invisible and pre-existing (pristine DIVERGENT too). It is a real downstream bug in the var typespec of an alias-of-alias.
  * Owner: the typespec ground. No corpus row has this shape.
* **R5, a spaced based literal (`8'h A5`) shifts the later tokens on its line.**
  * Golden moves every later column on the line by -1.
  * Ours shrinks only the ends of spans that CONTAIN the literal
    (`basedLiteralSpaceCount`, EmitHelpers.h:652). Its users are ExprEmit.cpp
    21140/21777/21798/34460/36428, StmtEmit.cpp 6295-6356 and ModuleEmit.cpp
    38596/38618/38975.
  * Unifying it with L3 means removing the per-site shrink, which is in the
    sister ground.
  * Measured on g3 n_*_lits: line 11 `b` sits at `11.24` against golden `11.23`.
* **R6, the package typedef typespec stretch for logic/bit/int aliases.**
  * Golden's elaborated `logic_typespec pkg::uint8_t` reads `endln:11:35`: it
    stretches to the last declarator.
  * `pendingPkgTsStretch` is recorded only for struct and enum
    (ParamEmit.cpp:29540 and :29794, in the sister ground).
  * It is judge-invisible and plugin-invisible: typedef_package is IDENTICAL.
