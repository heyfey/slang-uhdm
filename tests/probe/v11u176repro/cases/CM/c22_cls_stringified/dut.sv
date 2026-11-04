// § tfArgClassMethodOrder176
`define S(n) `"n`"
package p;
  typedef enum {A, B, C} e_t;
  class k;
    string nm = `S(e_t);
    function void f(e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k o;
  initial begin o = new; o.f(B); end
endmodule
