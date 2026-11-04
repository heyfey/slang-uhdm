// § ovUnsizedBasedActualForm491
module m #(parameter A = 4, parameter B = A) (output logic [7:0] o); assign o = B; endmodule
module top; logic [7:0] o; m #(.B('h5)) u(o); endmodule
