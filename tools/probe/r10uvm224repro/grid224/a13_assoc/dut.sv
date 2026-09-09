package p224r;
   typedef logic [1:0] tr224_t;
endpackage
interface if224r();
   import p224r::*;
   tr224_t s_plain224;
   tr224_t s_dyn224  [];
   tr224_t s_que224  [$];
   tr224_t s_fix224  [2];
   tr224_t s_ass224  [string];
   tr224_t s_plain2224;
   tr224_t s_dyn2224 [];
endinterface
module m224r();
   import p224r::*;
   tr224_t u_plain224;
   tr224_t u_dyn224  [];
   tr224_t u_ass224  [string];
   tr224_t u_plain2224;
endmodule
module top224r;
endmodule
