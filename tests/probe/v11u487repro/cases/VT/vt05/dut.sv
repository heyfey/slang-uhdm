// § caFoldTsFollowsPa487
module m (output logic [7:0] o); localparam B = 8'hAB; assign o = B; endmodule
module top; logic [7:0] o; m u(o); endmodule
