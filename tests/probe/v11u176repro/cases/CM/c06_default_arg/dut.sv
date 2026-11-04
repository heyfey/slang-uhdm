// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class k;
    function void f(e_t x = B);
    endfunction
    task t(int n, e_t y = C);
    endtask
  endclass
endpackage
module top;
  import p::*;
  k o;
  initial begin o = new; o.f(); end
endmodule
