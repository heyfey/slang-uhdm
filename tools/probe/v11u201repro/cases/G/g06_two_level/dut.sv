// § genBlockBitsKeepsSelect200
module top(input logic [15:0] x, output logic [31:0] z);
  for (genvar i = 0; i < 2; i++) begin : a
    for (genvar j = 0; j < 2; j++) begin : b
      if (i == j) begin : c
        logic [31:0] t;
        assign t = $bits(x[i*4+j:0]) * 2;
      end
    end
  end
  assign z = a[0].b[0].c.t;
endmodule
