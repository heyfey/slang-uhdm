// § caFoldValueFollowsPa487
module m #(parameter A = 4) (output logic [3:0] o); localparam B = A * 5; assign o = B; endmodule
module top; logic [3:0] o; m #(.A(7)) u(o); endmodule
