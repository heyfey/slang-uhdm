// § ovRefUnszBasedFormCopy491v
module s #(parameter X = 4'd1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter logic [7:0] A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('hAb)) u(o); endmodule
