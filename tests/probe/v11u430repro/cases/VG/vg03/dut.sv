// § defGenLpNoBlockListed430
module top #(parameter S = 1) (input [3:0] i, output [3:0] o);
  case (S)
    0: begin : c0 localparam a = 3; assign o = i + a; end
    default: begin : cd localparam b = 4; assign o = i + b; end
  endcase
endmodule
