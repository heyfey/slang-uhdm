// § ovDefparamMaskWidth487
module m #(parameter byte A = 4) (output logic [15:0] o); assign o = A; endmodule
module top; logic [15:0] o; m u(o); defparam u.A = 300; endmodule
