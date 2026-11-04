// § caFoldTsFollowsPa487
module m (output logic [7:0] o); parameter A = 4; localparam B = A + 1; assign o = B; endmodule
module top; logic [7:0] o; m #(5) u(o); endmodule
