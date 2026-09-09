package p224s;
   typedef logic [1:0] ts224_t;
   class Cs224; int x; endclass
endpackage
interface if224s();
   import p224s::*;
   ts224_t v_as_fix224  [string][2];
   ts224_t v_fix_as224  [2][string];
   ts224_t v_as_dyn224  [string][];
   Cs224   v_cas224     [string];
   var     v_varas224   [string];
   ts224_t v_as2224     [ts224_t];
   int     v_ias224     [string];
   logic [3:0] v_las224 [string];
endinterface
module m224s();
   import p224s::*;
   ts224_t w_as_fix224  [string][2];
   ts224_t w_fix_as224  [2][string];
   Cs224   w_cas224     [string];
   var     w_varas224   [string];
   int     w_ias224     [string];
endmodule
module top224s;
endmodule
