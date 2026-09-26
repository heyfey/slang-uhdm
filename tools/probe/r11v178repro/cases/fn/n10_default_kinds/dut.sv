// § refFullNameThroughNamedExpr175
package p;
  localparam int W = 2;
  typedef enum {E0, E1} e_t;
  function automatic int f(int a = W, e_t e = E1, int b = W + 1, int c = $bits(e)); return a + e + b + c; endfunction
  task automatic t(output int o, input int a = W); o = a; endtask
endpackage
module top; import p::*; int r; initial begin r = f(); t(r); end endmodule
