// r10v224 adversarial arm — the two clauses of the transplanted predicate that
// do NOT ask about the header form: the EXPLICIT-PORT net and
// hasBareImplicitType (`var d;`).  Both now fire on an interface with an ANSI
// header, where the pass measured neither.
package p224v5;
   typedef logic [1:0] tv5_t;
   class Cv5_224; int x; endclass
endpackage

interface if224v5(input .p5_224(w5_224));
   import p224v5::*;
   tv5_t   w5_224;
   tv5_t   v5_td224;
   Cv5_224 v5_cls224;
   var     v5_bare224;
endinterface

interface if224v5b(input logic clk5_224);
   import p224v5::*;
   var   v5b_bare224;
   tv5_t v5b_td224;
   int   v5b_i224;
endinterface

module top224v5;
   logic c5_224;
   if224v5b u5_224(c5_224);
endmodule
