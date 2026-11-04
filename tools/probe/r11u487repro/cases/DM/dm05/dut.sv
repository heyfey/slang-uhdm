// § ovDefparamMaskWidth487
module m #(parameter logic [3:0] A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(5) u(o); defparam u.A = 20; endmodule
