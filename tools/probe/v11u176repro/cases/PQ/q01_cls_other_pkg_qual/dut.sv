// § tfArgQualOutsideWriter176
package q;
  typedef enum {A, B, C} e_t;
endpackage
package p;
  class k;
    function void f(q::e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k o;
  initial begin o = new; o.f(q::B); end
endmodule
