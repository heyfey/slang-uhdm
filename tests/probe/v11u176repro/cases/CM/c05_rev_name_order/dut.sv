// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class zz;
    function void f(e_t x);
    endfunction
  endclass
  class aa;
    function void g(input e_t y);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  zz o; aa r;
  initial begin o = new; r = new; o.f(B); r.g(C); end
endmodule
