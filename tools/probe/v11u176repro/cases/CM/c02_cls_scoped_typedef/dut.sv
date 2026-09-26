// § tfArgClassMethodOrder176
package p;
  class k;
    typedef enum {A, B, C} e_t;
    function void f(e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k o;
  initial begin o = new; o.f(k::B); end
endmodule
