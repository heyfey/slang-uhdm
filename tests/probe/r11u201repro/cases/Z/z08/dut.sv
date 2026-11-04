// § genBlockBitsKeepsSelect200
module sub (input logic [3:0][7:0] x, output logic [31:0] z);
  if (1) begin : g
    assign z = $bits(x[1]);
  end
endmodule
module top (input logic [3:0][7:0] x, output logic [31:0] z);
  sub u (.*);
endmodule
