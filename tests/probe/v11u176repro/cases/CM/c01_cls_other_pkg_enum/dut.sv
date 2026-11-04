// § tfArgClassMethodOrder176
package q;
  typedef enum {A, B, C} e_t;
endpackage
package p;
  import q::*;
  class k;
    function void f(e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  k o;
  initial begin o = new; o.f(B); end
endmodule
