// § caFoldValueFollowsPa487
module m #(parameter A = 4) (output logic [3:0] o); localparam B = A << 3; assign o = B; endmodule
module top; logic [3:0] o; m u(o); defparam u.A = 3; endmodule
