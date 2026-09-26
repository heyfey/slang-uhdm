// § genNetDeclAssignLhsShared164 — a signed vector net declaration from a module-level path inside a gen-for block
module top(input [3:0] a, output [7:0] o);
  wire [3:0] base = a;
  for (genvar i = 0; i < 2; i++) begin : g
    wire signed [3:0] z = top.base;
    assign o[i*4 +: 4] = z;
  end
endmodule
