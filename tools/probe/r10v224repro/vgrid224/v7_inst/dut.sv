// r10v224 adversarial arm — the ELABORATED view of an INSTANTIATED interface
// must not move: the law is a DEFINITION-view law.
package p224v7;
   typedef logic [1:0] tv7_t;
   class Cv7_224; int x; endclass
endpackage

interface if224v7();
   import p224v7::*;
   tv7_t   v7_td224;
   tv7_t   v7_ass224 [string];
   tv7_t   v7_fix224 [2];
   tv7_t   v7_dyn224 [];
   Cv7_224 v7_cls224;
   int     v7_i224;
endinterface

module top224v7;
   if224v7 u7_224();
endmodule
