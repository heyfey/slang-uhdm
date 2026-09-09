package p224k;
   typedef logic [1:0] tk224_t;
   class Ck224; int x; endclass
endpackage
interface if224k();
   import p224k::*;
   tk224_t k_fix224 [2];
   tk224_t k_dyn224 [];
   tk224_t k_que224 [$];
   tk224_t k_ass224 [string];
   tk224_t k_pk224;
   Ck224   k_cfix224 [2];
   Ck224   k_cdyn224 [];
   Ck224   k_cque224 [$];
   Ck224   k_cass224 [string];
   int     k_ifix224 [2];
   int     k_idyn224 [];
   int     k_ique224 [$];
   int     k_iass224 [string];
   logic [3:0] k_lfix224 [2];
   logic [3:0] k_ldyn224 [];
endinterface
interface if224l(input logic clk224);
   import p224k::*;
   tk224_t l_fix224 [2];
   tk224_t l_dyn224 [];
   Ck224   l_cdyn224 [];
   int     l_idyn224 [];
endinterface
module top224k;
   logic c224;
   if224l u_l224(c224);
endmodule
