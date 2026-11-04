// § ovDefparamMaskWidth487
module m #(parameter bit [3:0] A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m u(o); defparam u.A = 17; endmodule
