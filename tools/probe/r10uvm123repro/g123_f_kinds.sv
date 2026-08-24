// r10uvm123 arm F — the KIND grid: a class method casts an enum, a packed
// struct, a packed-array-of-typedef and a plain-bound vector typedef of the
// home package, so the fence "vector typedefs only" is tested from both sides.
package fir123_pkg;
  typedef bit [7:0] fir_byte_t;
  typedef fir_byte_t [3:0] FIR_WORD_T;           // packed array of a typedef
  typedef enum logic [1:0] { F_LO123 = 2'd0, F_HI123 = 2'd2 } fir_mode_e;
  typedef struct packed { bit [2:0] a; bit b; } Fir_Rec_T;
  typedef logic [31:0] fir_plain_lt;             // plain literal bound

  class Fir123;
    fir_byte_t   k_b;
    FIR_WORD_T   k_w;
    fir_mode_e   k_m;
    Fir_Rec_T    k_r;
    fir_plain_lt k_p;
    function int fcast(int u);
      k_b = fir_byte_t'(u);
      k_w = FIR_WORD_T'(u);
      k_m = fir_mode_e'(u);
      k_r = Fir_Rec_T'(u);
      k_p = fir_plain_lt'(u);
      return 9;
    endfunction
  endclass
endpackage

module fir123_top;
  import fir123_pkg::*;
  Fir123 f;
  initial f = new();
endmodule
