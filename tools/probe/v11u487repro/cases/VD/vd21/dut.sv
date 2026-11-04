// § dpDepPreDefparamValue487
module m #(parameter A = 4, parameter C = 1) (output logic [7:0] o); localparam B = A + C; assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; defparam u.C = 2; endmodule
