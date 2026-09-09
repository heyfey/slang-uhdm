// r10v224 adversarial arm — ONE interface definition, THREE instances, plus a
// GENERATE-block instance.  The definition view must be emitted once and must
// answer to the law; the three elaborated views must not.
package p224vb;
   typedef logic [1:0] tvb_t;
   class Cvb_224; int x; endclass
endpackage

interface if224vb();
   import p224vb::*;
   tvb_t   vb_td224;
   tvb_t   vb_ass224 [string];
   tvb_t   vb_fix224 [2];
   Cvb_224 vb_cls224;
   int     vb_i224;
endinterface

module top224vb;
   if224vb u1_224();
   if224vb u2_224();
   generate
      if (1) begin : g224
         if224vb u3_224();
      end
   endgenerate
endmodule
