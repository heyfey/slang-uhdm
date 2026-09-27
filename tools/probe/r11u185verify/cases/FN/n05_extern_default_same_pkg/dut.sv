// § refFullNameThroughNamedExpr175
package p;
  typedef enum {E0, E1, E2} e_t;
  localparam int W = 3;
  class k;
    extern function int f(int a = W, e_t e = E2);
    function int g(e_t e = E1, int b = W); return b + e; endfunction
  endclass
  function int k::f(int a = W, e_t e = E2); return a + e; endfunction
  task automatic t(output int o, input e_t e = E0, input int c = W); o = c + e; endtask
endpackage
module top; import p::*; k o; int r; initial begin o = new; r = o.f() + o.g(); t(r); end endmodule
