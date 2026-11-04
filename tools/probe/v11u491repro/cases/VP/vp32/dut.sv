// § ovRefUnszBasedFormCopy491v
module s #(parameter X = 1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o, o2; m #(.A('h5)) u(o); m #(.A('h5)) u2(o2); endmodule
