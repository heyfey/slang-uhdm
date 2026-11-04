// § caFoldTsFollowsPa487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
module top; logic [7:0] o1, o2; m #(.A(5)) u1(o1); m #(.A(9)) u2(o2); endmodule
