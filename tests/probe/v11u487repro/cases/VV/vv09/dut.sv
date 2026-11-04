// § caFoldValueFollowsPa487
module m (output logic [7:0] o); localparam B = 3000000000; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
