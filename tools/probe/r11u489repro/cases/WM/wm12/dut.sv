// § dpDepUnboundedEval489
module m #(parameter A = 2'd3) (output logic [7:0] o); localparam B = (A + 2'd1) / 2'd2; assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 1; endmodule
