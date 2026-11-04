// § ovDefparamMaskWidth487
module m #(parameter [3:0] A = 4) (output logic [31:0] o); assign o = A; endmodule
module top; logic [31:0] o; m #(.A(3)) u(o); defparam u.A = 300; endmodule
