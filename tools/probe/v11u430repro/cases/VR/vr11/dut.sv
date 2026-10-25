// § rngGenLpCaReadShape430v
module top #(parameter S = 1) (input [3:0] i, output [3:0] o);
  case (S)
    1: begin : c1 localparam [3:0] a = 2; assign o = i + a; end
    default: begin : cd assign o = i; end
  endcase
endmodule
