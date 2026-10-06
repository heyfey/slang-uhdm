// § genLoopDirectBoundPaConst262 (an imported package parameter as a direct bound, the module declaring no parameter of the name)
package p;
  parameter int W = 3;
endpackage
module sub import p::*; #(parameter int V = 1) (input logic [7:0] a, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i] = a[W:0];
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] o [2]);
  sub u(.a(a), .o(o));
endmodule
