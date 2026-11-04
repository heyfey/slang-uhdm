// § ovDefparamMaskWidth487
module m #(parameter logic [3:0] A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid (output logic [7:0] o); m u(o); endmodule
module top; logic [7:0] o; mid x(o); defparam x.u.A = 20; endmodule
