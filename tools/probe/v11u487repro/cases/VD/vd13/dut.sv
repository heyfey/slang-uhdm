// § dpDepPreDefparamValue487
module n #(parameter X = 1) (output logic [7:0] o); assign o = X; endmodule
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A + 1; n #(.X(B)) v(o); endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 6; endmodule
