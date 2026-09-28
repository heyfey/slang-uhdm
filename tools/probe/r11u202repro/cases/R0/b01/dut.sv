// § genBlockBitsKeepsSelect200
module b01 #(parameter W = 3)(input logic [7:0] x, output logic [31:0] z [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign z[i] = $bits(x[4:0]);
  end
endmodule
