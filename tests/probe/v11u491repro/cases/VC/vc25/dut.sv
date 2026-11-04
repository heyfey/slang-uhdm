// § unboundedDepBesideDefparam491
module m #(parameter A = 4'd15, parameter X = 1) (output logic [7:0] o); localparam B = A + 4'd1; assign o = B; endmodule
module top; logic [7:0] o, o2; m u(o); m u2(o2); defparam u.X = 2; defparam u2.A = 4'd2; endmodule
