// § genBodyBitsOuterNameKeeps429
module top (input logic [7:0] a, output logic [7:0] y);
  logic [4:0] x;
  if (1) begin: g
    always_comb y = a[$bits(x)-1:0];
  end
endmodule
