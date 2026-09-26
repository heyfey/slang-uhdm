// § refFullNameThroughNamedExpr175
package p0; localparam int X = 7; typedef enum {A0, A1} e_t; endpackage
package p1;
  import p0::*;
  function automatic int f(int a = p0::X, int b = X, e_t e = A1); return a + b + e; endfunction
endpackage
module top; int r; initial r = p1::f(); endmodule
