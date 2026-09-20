// g1 - LAW A: a DIMENSION-LESS net whose written typedef is a PACKED ARRAY OF
// AN ALIAS (and the whole keyword x chain x home face around it).  The landed
// `aliasOfAlias0` guard (ModuleEmit def net loop) zeroes every one of these;
// golden zeroes only the ones whose typedef is homed in a PACKAGE or in $unit,
// where the DummyType keeps its compile-time typespec (CompileHelper.cpp:
// 898-905) and bindTypedefs_ never rebinds it (ElaborationStep.cpp:181-189),
// so the signal rewrite at :1491 sees DUMMY instead of SIMPLE_TYPEDEF.
// Every typedef here sorts AFTER its target, so no cell depends on bind order.
typedef logic [1:0] uv_t;          // $unit SimpleType
typedef uv_t [1:0]  uw_t;          // $unit packed-array-of-alias
typedef uv_t        uv2_t;         // $unit alias-of-alias
package pg1;
  typedef logic [1:0] pv_t;
  typedef pv_t [1:0]  pw_t;        // PACKAGE packed-array-of-alias
  typedef pv_t        pv2_t;
endpackage
module dut (output logic [1:0] o, input uw_t pin);
  import pg1::*;
  typedef logic [1:0] v_t;
  typedef v_t [1:0]   w_t;         // LOCAL packed-array-of-alias
  typedef reg [1:0]   r_t;
  typedef r_t [1:0]   rw_t;        // LOCAL packed-array-of-REG-alias
  typedef bit [1:0]   b_t;
  typedef b_t [1:0]   bw_t;        // LOCAL packed-array-of-BIT-alias
  typedef v_t         v2_t;        // LOCAL alias-of-alias

  w_t  a1;        // LAW A                      PREDICT 36
  wire w_t a2;    // LAW A + wire keyword       PREDICT 36
  wand w_t a3;    // LAW A + wand keyword       PREDICT 36
  rw_t a4;        // reg chain                  PREDICT 48
  bw_t a5;        // bit chain                  PREDICT 0
  v2_t a6;        // plain alias-of-alias       PREDICT 36 (already ours)
  w_t  a7 [2];    // pass-64 ground             PREDICT 36 (already ours)
  pw_t a8;        // PACKAGE-homed              PREDICT 0
  uw_t a9;        // $unit-homed                PREDICT 0
  pv2_t a10;      // PACKAGE alias-of-alias     PREDICT 0  (LAW B)
  uv2_t a11;      // $unit alias-of-alias       PREDICT 0  (LAW B)
  wire rw_t a12;  // keyword + reg chain
  wire r_t  a13;  // keyword + reg SimpleType
  // wire bw_t a14 -- SLANG REJECTS a two-state net type (golden: 1); R-SLANG
  wire pw_t a15;  // keyword + PACKAGE chain
  wire uw_t a16;  // keyword + $unit chain
  wire pv2_t a17; // keyword + PACKAGE alias-of-alias
  wire v2_t a18;  // keyword + LOCAL alias-of-alias
  wand pw_t a19;  // wand + PACKAGE chain
  wire uv_t a20;  // keyword + $unit SimpleType
  assign o = a1[0] | a2[0] | a3[0] | a4[0] | a5[0] | a6 | a7[0][0] |
             a8[0] | a9[0] | a10 | a11 | pin[0] | a12[0] | a13 |
             a15[0] | a16[0] | a17 | a18 | a19[0] | a20;
endmodule
