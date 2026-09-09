package p224i;
   typedef logic [1:0] ti224_t;
   class Ci224; int x; endclass
endpackage
interface if224i();
   import p224i::*;
   ti224_t  ii_td224;
   Ci224    ii_cls224;
   int      ii_i224;
   ti224_t  ii_dyn224 [];
   ti224_t  ii_fix224 [2];
endinterface
interface if224j();
   import p224i::*;
   ti224_t  ij_td224;
   Ci224    ij_cls224;
   int      ij_i224;
endinterface
module top224i;
   if224i u_i224();
endmodule
