// § genLoopDirectBoundPaConst262 (a module parameter shadowing an imported one, a direct bound on the left side of a for-generate assignment)
package p;
  parameter int W = 2;
endpackage
module sub import p::*; #(parameter int W = 3) (input logic [7:0] a, output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign o[i][W:0] = a[3:0];
  end
endmodule
module top(input logic [7:0] a, output logic [7:0] o [2]);
  sub #(.W(3)) u(.a(a), .o(o));
endmodule
