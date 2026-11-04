// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [31:0] y);
  wire [4:0] x;
  case (W)
    1: assign y = 0;
    default: begin : d
      assign y = $bits(x) - 1;
    end
  endcase
endmodule
