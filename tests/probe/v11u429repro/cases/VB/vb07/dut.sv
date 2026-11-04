// § genBodyBitsOuterNameKeeps429
module top #(parameter S = 1) (output logic [3:0] y);
  logic [5:0] x;
  case (S)
    1: begin: g
      always_comb y = $bits(x);
    end
    default: begin: d
      always_comb y = 0;
    end
  endcase
endmodule
