// g2 - LAW B: a DIMENSION-LESS net written with a PACKAGE (or $unit) alias.
// A package/FileContent typedef over a NAMED type gets its typespec at compile
// time (CompileHelper.cpp:898-905) so bindTypedefs_ NEVER rebinds its
// DummyType (ElaborationStep.cpp:181), and the signal rewrite at :1491 sees
// category DUMMY, not SIMPLE_TYPEDEF: NO net type.  A package typedef over a
// BUILT-IN is a SimpleType and keeps its 36/48 in every home.
typedef logic [1:0] uv_t;
typedef uv_t        uv2_t;
package pk;
  typedef logic [1:0] cv_t;     // SimpleType
  typedef cv_t        cv2_t;    // alias-of-alias
  typedef cv_t [1:0]  cw_t;     // packed-array-of-alias
  typedef reg  [1:0]  cr_t;     // SimpleType (reg)
  typedef cr_t        cr2_t;    // alias-of-REG-alias
endpackage
module dut (output logic [1:0] o);
  import pk::*;
  cv_t   e1;      // PACKAGE single alias          PREDICT 36
  cv2_t  e2;      // PACKAGE alias-of-alias        PREDICT 0   (LAW B)
  cw_t   e3;      // PACKAGE packedarr-of-alias    PREDICT 0
  cr_t   e4;      // PACKAGE reg alias             PREDICT 48
  cr2_t  e5;      // PACKAGE alias-of-reg-alias    PREDICT 0
  pk::cv_t e6;    // SCOPED name                   PREDICT 0 (landed rule)
  uv_t   e7;      // $unit single alias            PREDICT 36
  uv2_t  e8;      // $unit alias-of-alias          PREDICT 0   (LAW B)
  typedef cv_t  l1_t;   // LOCAL typedef over a package SimpleType
  typedef cv2_t l2_t;   // LOCAL typedef over a package DUMMY
  l1_t f1;        //                                PREDICT 36
  l2_t f2;        //                                PREDICT 0
  assign o = e1 | e2 | e3[0] | e4 | e5 | e6 | e7 | e8 | f1 | f2;
endmodule
