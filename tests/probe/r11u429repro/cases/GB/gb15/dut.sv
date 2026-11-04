// § genBodyBitsOuterNameKeeps429
module top (output logic [3:0] y);
  logic [4:0] x;
  if (1) begin: g
    initial y = $bits(x);
  end
endmodule
