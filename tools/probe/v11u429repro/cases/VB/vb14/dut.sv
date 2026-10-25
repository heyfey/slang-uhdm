// § genBodyBitsOuterNameKeeps429
module top (input logic [3:0] s, output logic [3:0] y);
  logic [4:0] x;
  if (1) begin: g
    always_comb case (s)
      $bits(x): y = 1;
      default: y = 0;
    endcase
  end
endmodule
