// § caFoldTsFollowsPa487
module m (output logic [7:0] o); localparam B = 'd7; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
