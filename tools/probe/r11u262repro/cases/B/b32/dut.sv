// § genLoopDirectBoundPaConst262 (for-generate in an interface instance, typed overridden width and direct bound)
interface ifc #(parameter int Width = 32) (input logic [7:0] a);
  logic [5:0] q;
  for (genvar i = 0; i < 2; i++) begin : gf
    assign q[i*3+:3] = a[i+:Width] | a[Width:1];
  end
endinterface
module top(input logic [7:0] a, output logic [5:0] q);
  ifc #(.Width(3)) i (.a(a));
  assign q = i.q;
endmodule
