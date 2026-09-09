package p224c;
   class Cc224;
      int x;
   endclass
   typedef struct packed { int a; } sc224_t;
   typedef int tc224_t;
endpackage

// empty-parens header (MiniAmiq's form)
interface if224_ep();
   import p224c::*;
   Cc224   e_cls224;
   Cc224   e_clsdyn224 [];
   sc224_t e_sp224;
   tc224_t e_ti224;
   tc224_t e_tidyn224 [];
   int     e_int224;
   int     e_intdyn224 [];
   tc224_t e_tipk224 [1:0];
   p224c::tc224_t e_q224;
endinterface

// NO parens at all
interface if224_np;
   import p224c::*;
   Cc224   n_cls224;
   tc224_t n_ti224;
   tc224_t n_tidyn224 [];
   int     n_int224;
endinterface

// ANSI header
interface if224_an(input logic clk224);
   import p224c::*;
   Cc224   a_cls224;
   tc224_t a_ti224;
   tc224_t a_tidyn224 [];
   int     a_int224;
endinterface

// non-ANSI header with a real port list
interface if224_na(pa224);
   import p224c::*;
   input pa224;
   Cc224   b_cls224;
   tc224_t b_ti224;
   tc224_t b_tidyn224 [];
   int     b_int224;
endinterface

// module counterparts
module m224_ep();
   import p224c::*;
   Cc224   me_cls224;
   tc224_t me_ti224;
   tc224_t me_tidyn224 [];
   int     me_int224;
endmodule

module m224_an(input logic clk224);
   import p224c::*;
   Cc224   ma_cls224;
   tc224_t ma_ti224;
   tc224_t ma_tidyn224 [];
   int     ma_int224;
endmodule

module top224c;
   logic c;
   if224_an u_an(c);
endmodule
