// § dpConstUintForm489
module m #(parameter logic [3:0] A = 4'd15) (output logic [7:0] o); localparam B = 1; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; endmodule
