// § genBlockBitsKeepsSelect200
module sub (input logic [31:0] x, output logic [31:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [31:0] w;
    always_comb w = $bits(x[i+2:0]);
  end
  assign z = g[0].w;
endmodule
module top (input logic [31:0] x, output logic [31:0] z);
  sub u (.*);
endmodule
