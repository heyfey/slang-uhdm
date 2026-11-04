// § caFoldValueFollowsPa487
module m (output logic [3:0] o); localparam B = 'hFF; assign o = B; endmodule
module top; logic [3:0] o; m u(o); endmodule
