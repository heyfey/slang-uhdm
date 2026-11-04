// § dpDepUnboundedEval489
module m #(parameter A = 4'd15) (output logic [7:0] o); localparam B = A + 1; assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; endmodule
