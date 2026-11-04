// § caFoldTsFollowsPa487
module m (output logic [7:0] o); localparam B = 64'hFFFF_FFFF_FFFF_FFFF; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
