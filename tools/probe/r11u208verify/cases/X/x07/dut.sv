// § genBlockBitsKeepsSelect200 § defGenInitRhsKeepsParent200 § genVarInitOuterRefUnbound202
module x07 (input logic [15:0] x, output logic [31:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [31:0] b = $bits(x[7:0]);
    wire [31:0] c;
    assign c = $bits(x[i +: 3]);
  end
  assign z = g[0].b + g[1].c;
endmodule
