// § dpDepPreDefparamValue487
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
module top; logic [7:0] o1, o2; m u1(o1); m u2(o2); defparam u1.A = 6; endmodule
