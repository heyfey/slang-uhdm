// § caFoldTsFollowsPa487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A + 1; wire [7:0] w = B; assign o = w; endmodule
module top; logic [7:0] o; m u(o); endmodule
