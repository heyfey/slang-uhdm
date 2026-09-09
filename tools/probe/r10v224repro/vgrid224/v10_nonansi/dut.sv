// r10v224 adversarial arm — the associative reprieve under a GENUINE non-ANSI
// interface port list (the pass measured the reprieve only under empty parens).
package p224va;
   typedef logic [1:0] tva_t;
endpackage

interface if224va(pa224va);
   import p224va::*;
   input pa224va;
   tva_t va_td224;
   tva_t va_ass224 [string];
   tva_t va_dyn224 [];
   tva_t va_fix224 [2];
endinterface

module m224va(pa224vb);
   import p224va::*;
   input pa224vb;
   tva_t vb_td224;
   tva_t vb_ass224 [string];
endmodule

module top224va;
endmodule
