// § caFoldTsFollowsPa487
module m (output logic [7:0] o); parameter B = 2 * 3; assign o = B; endmodule
module top; logic [7:0] o; m #(.B(9)) u(o); endmodule
