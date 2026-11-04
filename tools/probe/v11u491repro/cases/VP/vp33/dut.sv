// § ovRefUnszBasedFormCopy491v
module s #(parameter X = 1) (output logic [7:0] o); assign o = X + 1; endmodule
module m #(parameter A = 4) (output logic [7:0] o); s #(.X(A)) c(o); endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); defparam u.c.X = 'h3; endmodule
