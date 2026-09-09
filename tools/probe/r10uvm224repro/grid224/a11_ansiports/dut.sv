package p224n;
   typedef logic [1:0] tn224_t;
   class Cn224; int x; endclass
endpackage
interface if224n(input logic clk224, output p224n::tn224_t o224);
   import p224n::*;
   tn224_t n_td224;
   Cn224   n_cls224;
   int     n_i224;
   tn224_t n_dyn224 [];
endinterface
module top224n;
   logic c224;
   logic [1:0] o224;
   if224n u_n224(c224, o224);
endmodule
