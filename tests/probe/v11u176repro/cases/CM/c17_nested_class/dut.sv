// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class outer;
    class inner;
      function void f(e_t x);
      endfunction
    endclass
    function void g(e_t y);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  outer o;
  initial begin o = new; o.g(B); end
endmodule
