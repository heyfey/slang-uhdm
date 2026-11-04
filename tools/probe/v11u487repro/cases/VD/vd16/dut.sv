// § dpDepPreDefparamValue487
module m #(parameter A = 4, parameter W = 2) (output logic [7:0] o); localparam B = A + W; assign o = B; endmodule
module top; logic [7:0] o; m #(.W(1+2)) u(o); defparam u.A = 6; endmodule
