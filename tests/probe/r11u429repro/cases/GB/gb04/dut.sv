// § genBodyBitsOuterNameKeeps429
module top (output [3:0] y);
  if (1) begin: g
    logic [4:0] z;
    if (1) begin: h
      assign y = $bits(z);
    end
  end
endmodule
