// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  function automatic int g(e_t y);
    return int'(y);
  endfunction
  class k;
    function void f(e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k o;
  int r;
  initial begin o = new; o.f(B); r = g(C); end
endmodule
