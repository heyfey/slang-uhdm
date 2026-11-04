// § dpDepPreDefparamValue487
module m #(parameter A = 4) (output logic [7:0] o); generate if (1) begin : g localparam B = A + 1; assign o = B; end endgenerate endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; endmodule
