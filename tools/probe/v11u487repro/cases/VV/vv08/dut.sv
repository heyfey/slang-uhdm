// § caFoldValueFollowsPa487
module m (output logic [7:0] o); localparam B = 1'bx; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
