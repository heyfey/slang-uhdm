// § dpDepUnboundedEval489
module m #(parameter A = 4'd9) (output logic [7:0] o); localparam B = A * 4'd3; assign o = B; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; endmodule
