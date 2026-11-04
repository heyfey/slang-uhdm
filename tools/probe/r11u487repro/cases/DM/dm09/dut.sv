// § ovDefparamMaskWidth487
module m #(parameter logic [5:0] A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.A(5)) u(o); defparam u.A = 4'd13; endmodule
