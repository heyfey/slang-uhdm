// r10v224 adversarial arm — a FIXED unpacked array of a STRUCT typedef in an
// empty-parens interface.  The base net is now stripped, which routes the
// array_net's inner element net down the new `VpiNetType(36)` branch instead
// of the structElemTs branch it used to take.
package p224v6;
   typedef struct packed { logic [3:0] a; } sp6_t;
   typedef struct { logic [3:0] a; int b; } su6_t;
   typedef logic [1:0] tv6_t;
endpackage

interface if224v6();
   import p224v6::*;
   sp6_t         v6_sparr224  [1:0];
   su6_t         v6_suarr224  [1:0];
   p224v6::sp6_t v6_qsparr224 [1:0];
   tv6_t         v6_tdarr224  [1:0];
   int           v6_iarr224   [1:0];
endinterface

module top224v6;
endmodule
