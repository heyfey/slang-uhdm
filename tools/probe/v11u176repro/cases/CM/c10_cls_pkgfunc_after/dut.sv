// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class k;
    function void f(e_t x);
    endfunction
  endclass
  function automatic int g(e_t y);
    return int'(y);
  endfunction
endpackage
module top;
  import p::*;
  k o;
  int r;
  initial begin o = new; o.f(B); r = g(C); end
endmodule
