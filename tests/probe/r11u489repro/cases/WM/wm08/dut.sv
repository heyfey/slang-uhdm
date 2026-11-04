// § dpDepUnboundedEval489
module m #(parameter A = 3'd7) (output logic [7:0] o); localparam B = A + A; assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 1; endmodule
