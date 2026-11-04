// § genNetDeclAssignLhsShared164 § genProcFoldDeclTsScopeNamed167 — ONE gen-if scope holding an absolute-path net declaration and a folded parameter in a process
module top #(parameter int W = 4, parameter logic [W-1:0] Z = 4'd3) (input logic clk, input logic a, output logic o, output logic [W-1:0] q);
  wire src = a;
  if (W > 1) begin : g
    wire z = top.src;
    always_ff @(posedge clk) q <= Z;
  end
  assign o = g.z;
endmodule
