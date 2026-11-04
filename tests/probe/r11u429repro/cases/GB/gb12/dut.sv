// § genBodyBitsOuterNameKeeps429
module top (output [3:0] y);
  logic [4:0] x;
  case (1)
    1: begin: g
      assign y = $bits(x) - 1;
    end
  endcase
endmodule
