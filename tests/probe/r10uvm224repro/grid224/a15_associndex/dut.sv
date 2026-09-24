package p224t;
   typedef logic [1:0] tt224_t;
   typedef int         ti2224_t;
endpackage
interface if224t();
   import p224t::*;
   typedef logic [3:0] loct224_t;
   tt224_t x_str224   [string];
   tt224_t x_int224   [int];
   tt224_t x_wild224  [*];
   tt224_t x_scoped224[p224t::tt224_t];
   tt224_t x_bare224  [tt224_t];
   tt224_t x_local224 [loct224_t];
   tt224_t x_logic224 [logic];
   tt224_t x_bit224   [bit];
   tt224_t x_scint224 [p224t::ti2224_t];
endinterface
module top224t;
endmodule
