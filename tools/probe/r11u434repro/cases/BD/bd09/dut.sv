// § genBodyDefBitsKeepsCall434
module top #(parameter M = 1) (output [31:0] y);
  logic [6:0] x;
  case (M)
    1: assign y = $bits(x);
    default: assign y = 0;
  endcase
endmodule
