// § tfArgClassMethodOrder176
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  class k;
    function void f(s_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k o;
  initial begin o = new; o.f('0); end
endmodule
