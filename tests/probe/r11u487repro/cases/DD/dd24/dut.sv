// § dpDepPreDefparamValue487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
module mid(output logic [7:0] o); m u(o); endmodule
module top; logic [7:0] o; mid x(o); defparam x.u.A = 6; endmodule
