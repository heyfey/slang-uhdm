package p224g;
   typedef logic [3:0] tg224_t;
   class Cg224; int x; endclass
   tg224_t  gv_td224;
   tg224_t  gv_tddyn224 [];
   Cg224    gv_cls224;
   int      gv_int224;
   int      gv_intdyn224 [];
endpackage

interface if224g();
   import p224g::*;
   int own_g224;
endinterface

module m224g();
   import p224g::*;
   int own_mg224;
endmodule

module top224g;
endmodule
