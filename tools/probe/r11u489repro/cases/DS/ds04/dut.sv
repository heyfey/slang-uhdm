// § dpConstUintForm489
module m #(parameter A = 4'hF) (output logic [7:0] o); localparam B = 1; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; endmodule
