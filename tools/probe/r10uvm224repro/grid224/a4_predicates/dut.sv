package p224d;
   typedef int td224_t;
   class Cd224; int x; endclass
endpackage

interface if224d();
   import p224d::*;
   td224_t d_init224 = 0;          // NamedType WITH initializer
   td224_t d_noinit224;            // NamedType no initializer
   var d_bare224;                  // bare implicit variable
   int     d_i224;
   wire    d_w224;
   typedef logic [2:0] loc224_t;   // LOCAL typedef
   loc224_t d_loc224;
   loc224_t d_locdyn224 [];
   p224d::td224_t d_scoped224;
   logic   d_lg224;
   logic signed [1:0] d_sg224;
   real    d_re224;
   string  d_st224;
   Cd224   d_cls224;
endinterface

module m224d();
   import p224d::*;
   td224_t e_init224 = 0;
   td224_t e_noinit224;
   var e_bare224;
   typedef logic [2:0] loce224_t;
   loce224_t e_loc224;
   p224d::td224_t e_scoped224;
   real e_re224;
   string e_st224;
   Cd224 e_cls224;
endmodule

module top224d;
endmodule
