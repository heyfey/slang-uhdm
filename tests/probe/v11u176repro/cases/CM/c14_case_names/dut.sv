// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class abc;
    function void f(e_t x);
    endfunction
  endclass
  class Zed;
    function void g(e_t y);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  abc o; Zed z;
  initial begin o = new; z = new; o.f(B); z.g(C); end
endmodule
