// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  logic [4:0] x;
  if (1) begin: g
    initial $display("%0d", $bits(x));
    always_comb y = 1;
  end
endmodule
