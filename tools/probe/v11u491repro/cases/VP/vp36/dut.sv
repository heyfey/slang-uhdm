// § ovRefUnszBasedFormCopy491v
module s #(parameter X = 1, parameter Z = X) (output logic [7:0] o); assign o = Z + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
