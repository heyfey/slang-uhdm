// § ovRefUnszBasedFormCopy491v
module g #(parameter Y = 1) (output logic [7:0] o); assign o = Y + 1; endmodule
module s #(parameter X = 1) (output logic [7:0] o); g #(.Y(X)) d(o); endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
