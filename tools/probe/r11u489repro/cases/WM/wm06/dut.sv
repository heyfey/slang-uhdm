// § dpDepUnboundedEval489
module m #(parameter A = 4'd12) (output logic [7:0] o); localparam B = A << 2; assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; endmodule
