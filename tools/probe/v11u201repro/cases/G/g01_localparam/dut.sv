// § genBlockBitsKeepsSelect200
module top(input logic [15:0] x, output logic [31:0] z, output logic [31:0] z2);
  if (1) begin : g
    localparam int L = $bits(x[3:0]);
    assign z = L;
    wire [$bits(x[5:0])-1:0] w = '0;
    assign z2 = $bits(w);
  end
endmodule
