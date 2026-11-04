// § dpDepPreDefparamValue487
module m #(parameter A = 4) (output logic [7:0] o); localparam logic [2:0] B = A + 3; assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; endmodule
