# r10ladder1 — CLUSTER REPORT

Instrument: `ctladder` (MEASUREMENT-ONLY; the official `uhdm-cmp` remains the sole acceptance judge).  Every rung below is a real `design::Compare` head under official semantics — the walk, the field order and the failure points are UHDM's own.

## Per-row ladder length (the first honest 'how far are we')

| row | rungs | stop | deepest walk (golden objs proven equal) | masks | secs |
|---|---:|---|---|---:|---:|
| default_FileLocalParam | 2 | FIXPOINT | 104/117 | 2 | 0.0 |
| default_HierPathEval | 3 | FIXPOINT | 187/191 | 3 | 0.0 |
| default_TopParam | 1 | ROOT-BLOCKED | 1/99 | 0 | 0.0 |
| default_UnsignedParam | 1 | FIXPOINT | 168/171 | 1 | 0.0 |
| testflags_FileLocalParam | 4 | FIXPOINT | 24/36 | 4 | 0.0 |
| testflags_HierPathEval | 3 | FIXPOINT | 103/115 | 3 | 0.0 |
| testflags_TopParam | 1 | ROOT-BLOCKED | 1/15 | 0 | 0.0 |
| testflags_UnsignedParam | 1 | FIXPOINT | 84/87 | 1 | 0.0 |

Rows whose ladder is TRUNCATED (stop != FIXPOINT), so their length is a strict LOWER bound: **default_TopParam, testflags_TopParam**

Every ladder length is a lower bound in a second way as well: masking an object skips its WHOLE SUBTREE, so any defect inside a masked subtree is invisible to later rungs (see `masked=` per rung).

## Per-row family profile (top 5 by entries)

| row | rungs | top families |
|---|---:|---|
| default_FileLocalParam | 2 | `ref_typespec\|<rhs-null>\|MISSING-OURS` x1<br>`operation\|<rhs-null>\|MISSING-OURS` x1 |
| default_HierPathEval | 3 | `constant\|VpiDecompile\|DIGITS-ONLY` x2<br>`gen_scope_array\|VpiName\|TEXT:gen_inner_if_true\|gen_inner_if_false` x1 |
| default_TopParam | 1 | `design\|VpiName\|TEXT:work@top\|unnamed` x1 |
| default_UnsignedParam | 1 | `module_inst\|<rhs-null>\|MISSING-OURS` x1 |
| testflags_FileLocalParam | 4 | `ref_typespec\|<rhs-null>\|MISSING-OURS` x1<br>`constant\|<rhs-null>\|MISSING-OURS` x1<br>`constant\|VpiType\|KIND:constant>ref_obj` x1<br>`module_inst\|<rhs-null>\|MISSING-OURS` x1 |
| testflags_HierPathEval | 3 | `constant\|VpiDecompile\|DIGITS-ONLY` x2<br>`gen_scope_array\|VpiName\|TEXT:gen_inner_if_true\|gen_inner_if_false` x1 |
| testflags_TopParam | 1 | `design\|VpiName\|TEXT:work@top\|unnamed` x1 |
| testflags_UnsignedParam | 1 | `module_inst\|<rhs-null>\|MISSING-OURS` x1 |

## FAMILIES (kind | field | value shape)

| rank | rows | entries | family |
|---:|---:|---:|---|
| 1 | 3 | 3 | `module_inst\|<rhs-null>\|MISSING-OURS` |
| 2 | 2 | 4 | `constant\|VpiDecompile\|DIGITS-ONLY` |
| 3 | 2 | 2 | `design\|VpiName\|TEXT:work@top\|unnamed` |
| 4 | 2 | 2 | `gen_scope_array\|VpiName\|TEXT:gen_inner_if_true\|gen_inner_if_false` |
| 5 | 2 | 2 | `ref_typespec\|<rhs-null>\|MISSING-OURS` |
| 6 | 1 | 1 | `constant\|<rhs-null>\|MISSING-OURS` |
| 7 | 1 | 1 | `constant\|VpiType\|KIND:constant>ref_obj` |
| 8 | 1 | 1 | `operation\|<rhs-null>\|MISSING-OURS` |

### Example cells (up to 3 per family, in rank order)

**F1 `module_inst|<rhs-null>|MISSING-OURS`** — 3 entries in 3 row(s): default_UnsignedParam, testflags_FileLocalParam, testflags_UnsignedParam

  - `default_UnsignedParam` rung 1
    - L(golden) `module_inst(work@top)@dut.sv:4:1-13:10`
    - R(ours)   `<null>`
    - G= -   O= -
  - `testflags_FileLocalParam` rung 4
    - L(golden) `module_inst(work@top)@dut.sv:11:1-19:10`
    - R(ours)   `<null>`
    - G= -   O= -
  - `testflags_UnsignedParam` rung 1
    - L(golden) `module_inst(work@top)@dut.sv:4:1-13:10`
    - R(ours)   `<null>`
    - G= -   O= -

**F2 `constant|VpiDecompile|DIGITS-ONLY`** — 4 entries in 2 row(s): default_HierPathEval, testflags_HierPathEval

  - `default_HierPathEval` rung 1
    - L(golden) `constant@dut.sv:35:35-35:36`
    - R(ours)   `constant@:35:35-35:36`
    - G= "1"   O= "0"
  - `testflags_HierPathEval` rung 1
    - L(golden) `constant@dut.sv:35:35-35:36`
    - R(ours)   `constant@:35:35-35:36`
    - G= "1"   O= "0"
  - `default_HierPathEval` rung 2
    - L(golden) `constant@dut.sv:21:44-21:45`
    - R(ours)   `constant@:21:44-21:45`
    - G= "1"   O= "0"

**F3 `design|VpiName|TEXT:work@top|unnamed`** — 2 entries in 2 row(s): default_TopParam, testflags_TopParam

  - `default_TopParam` rung 1
    - L(golden) `design(work@top)@:0:0-0:0`
    - R(ours)   `design(unnamed)@:0:0-0:0`
    - G= "work@top"   O= "unnamed"
  - `testflags_TopParam` rung 1
    - L(golden) `design(work@top)@:0:0-0:0`
    - R(ours)   `design(unnamed)@:0:0-0:0`
    - G= "work@top"   O= "unnamed"

**F4 `gen_scope_array|VpiName|TEXT:gen_inner_if_true|gen_inner_if_false`** — 2 entries in 2 row(s): default_HierPathEval, testflags_HierPathEval

  - `default_HierPathEval` rung 3
    - L(golden) `gen_scope_array(gen_inner_if_true)@dut.sv:23:6-25:10`
    - R(ours)   `gen_scope_array(gen_inner_if_false)@:27:6-29:9`
    - G= "gen_inner_if_true"   O= "gen_inner_if_false"
  - `testflags_HierPathEval` rung 3
    - L(golden) `gen_scope_array(gen_inner_if_true)@dut.sv:23:6-25:10`
    - R(ours)   `gen_scope_array(gen_inner_if_false)@:27:6-29:9`
    - G= "gen_inner_if_true"   O= "gen_inner_if_false"

**F5 `ref_typespec|<rhs-null>|MISSING-OURS`** — 2 entries in 2 row(s): default_FileLocalParam, testflags_FileLocalParam

  - `default_FileLocalParam` rung 1
    - L(golden) `ref_typespec@:0:0-0:0`
    - R(ours)   `<null>`
    - G= -   O= -
  - `testflags_FileLocalParam` rung 1
    - L(golden) `ref_typespec@:0:0-0:0`
    - R(ours)   `<null>`
    - G= -   O= -

**F6 `constant|<rhs-null>|MISSING-OURS`** — 1 entries in 1 row(s): testflags_FileLocalParam

  - `testflags_FileLocalParam` rung 2
    - L(golden) `constant@dut.sv:3:33-5:48`
    - R(ours)   `<null>`
    - G= -   O= -

**F7 `constant|VpiType|KIND:constant>ref_obj`** — 1 entries in 1 row(s): testflags_FileLocalParam

  - `testflags_FileLocalParam` rung 3
    - L(golden) `constant@dut.sv:13:16-13:19`
    - R(ours)   `ref_obj(MAP)@:13:16-13:19`
    - G= constant   O= ref_obj

**F8 `operation|<rhs-null>|MISSING-OURS`** — 1 entries in 1 row(s): default_FileLocalParam

  - `default_FileLocalParam` rung 2
    - L(golden) `operation@dut.sv:3:33-5:48`
    - R(ours)   `<null>`
    - G= -   O= -

## COARSE FAMILIES (kind | field)

| rank | rows | entries | family |
|---:|---:|---:|---|
| 1 | 3 | 3 | `module_inst\|<rhs-null>` |
| 2 | 2 | 4 | `constant\|VpiDecompile` |
| 3 | 2 | 2 | `design\|VpiName` |
| 4 | 2 | 2 | `gen_scope_array\|VpiName` |
| 5 | 2 | 2 | `ref_typespec\|<rhs-null>` |
| 6 | 1 | 1 | `constant\|<rhs-null>` |
| 7 | 1 | 1 | `constant\|VpiType` |
| 8 | 1 | 1 | `operation\|<rhs-null>` |

