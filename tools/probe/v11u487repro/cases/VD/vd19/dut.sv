// § dpDepPreDefparamValue487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A + 1; localparam C = B * 2; assign o = C; endmodule
module top; logic [7:0] o; m #(5) u(o); defparam u.A = 9; endmodule
