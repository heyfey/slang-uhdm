// § dpDepPreDefparamValue487
module m #(parameter A = 4, parameter type T = int, parameter C = 2) (output logic [7:0] o); localparam B = C + 1; assign o = B; endmodule
module top; logic [7:0] o; m #(9, logic) u(o); defparam u.C = 2; endmodule
