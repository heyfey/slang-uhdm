// § ovDefparamMaskWidth487
module m #(parameter bit [2:0] A = 1) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.A(2)) u(o); defparam u.A = 9; endmodule
