// r10v224 adversarial arm — MIXED dimension chains the pass did not measure:
// a NAMED-index associative level above a built-in one, and dynamic/queue
// levels above an associative one.  The predicate says ANY level suffices.
package p224v4;
   typedef logic [1:0] tv4_t;
endpackage

interface if224v4();
   import p224v4::*;
   tv4_t v4_bs224 [tv4_t][string];
   tv4_t v4_db224 [][string];
   tv4_t v4_qb224 [$][string];
   tv4_t v4_sb224 [string][tv4_t];
   tv4_t v4_fb224 [2][2][string];
   tv4_t v4_plain224;
endinterface

module m224v4();
   import p224v4::*;
   tv4_t v4_mbs224 [tv4_t][string];
   tv4_t v4_mdb224 [][string];
   tv4_t v4_mplain224;
endmodule

module top224v4;
endmodule
