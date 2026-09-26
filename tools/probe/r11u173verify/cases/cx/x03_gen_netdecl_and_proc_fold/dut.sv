// § genNetDeclAssignLhsShared164 § genProcFoldDeclTsScopeNamed167 — one generate scope with a path net declaration and a folded parameter in a process
module top #(parameter int W = 4, parameter logic [W-1:0] Z = 4'd3) (input logic clk, input logic a, output logic o, output logic [W-1:0] q);
  if (1) begin : g
    wire x = a;
    if (1) begin : h
      wire z = g.x;
      always_ff @(posedge clk) q <= Z;
    end
  end
  assign o = g.h.z;
endmodule
