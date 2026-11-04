// § dpDepPreDefparamValue487
module m #(parameter A = 4, parameter type T = logic [A-1:0]) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
module top; logic [7:0] o; m #(5, logic [2:0]) u(o); defparam u.A = 6; endmodule
