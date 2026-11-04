// § genBlockBitsKeepsSelect200
module sub (input logic [31:0] x, output logic [31:0] z);
  for (genvar i = 0; i < 1; i++) begin : g
    for (genvar j = 0; j < 1; j++) begin : h
      assign z = $bits(x[5:0]) + 1;
    end
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] z);
  sub u (.*);
endmodule
