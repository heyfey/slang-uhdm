// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  logic [4:0] x;
  if (1) begin: g
    wire [2:0] w;
    always_comb y = $size(x) + $bits(w) + $bits(x);
  end
endmodule
