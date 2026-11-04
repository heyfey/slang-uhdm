// § dpDepUnboundedEval489
module m #(parameter A = 8'd255) (output logic [15:0] o); localparam B = A * 8'd2; assign o = B; endmodule
module top; logic [15:0] o; m u(o); defparam u.A = 6; endmodule
