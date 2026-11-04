// § caFoldTsFollowsPa487
module m #(parameter A = 4) (output logic [15:0] o); localparam B = A + 1; assign o = B; endmodule
module top; logic [15:0] o; m u(o); endmodule
