// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class k #(int N = 1);
    function void f(e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k #(2) o;
  initial begin o = new; o.f(B); end
endmodule
