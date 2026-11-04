// § dpConstUintForm489
module m #(parameter A = 8'd15) (output logic [7:0] o); localparam B = 1; endmodule
module top; logic [7:0] o; m #(.A(8'd3)) u(o); defparam u.A = 6; endmodule
