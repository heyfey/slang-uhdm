// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
endpackage
module sub (input logic [3:0] a, output logic [3:0] y); assign y = p::c(a); endmodule
module top (input [3:0] i, output [3:0] o);
  sub s0 (.a(i), .y(imp));
  for (genvar k = 0; k < 2; k++) begin : g
    logic [3:0] t;
    assign t = p::c(i + k);
  end
  assign o = imp;
endmodule
