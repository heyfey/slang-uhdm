// § ovDefparamMaskWidth487
module m #(parameter integer A = 4) (output logic [31:0] o); assign o = A; endmodule
module top; logic [31:0] o; m u(o); defparam u.A = 4294967297; endmodule
