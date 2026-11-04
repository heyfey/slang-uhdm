// § dpDepPreDefparamValue487
module m #(parameter type T = int, parameter A = 4, parameter C = 2) (output logic [7:0] o); localparam B = C + 1; assign o = B; endmodule
module top; logic [7:0] o; m #(int, 9, 3) u(o); defparam u.C = 7; endmodule
