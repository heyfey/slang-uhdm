// § tfArgClassMethodOrder176
`define M(n) function void n(e_t x); endfunction
package p;
  typedef enum {A, B, C} e_t;
  class k;
    `M(f)
  endclass
endpackage
module top;
  import p::*;
  k o;
  initial begin o = new; o.f(B); end
endmodule
