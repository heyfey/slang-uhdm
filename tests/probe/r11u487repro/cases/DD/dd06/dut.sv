// § dpDepPreDefparamValue487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A | 1; assign o = B; endmodule
module top; logic [7:0] o; m #(.A(5)) u(o); defparam u.A = 6; endmodule
