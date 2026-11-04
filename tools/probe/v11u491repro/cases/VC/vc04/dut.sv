// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o, o2; m #(.A('h5)) u(o); m u2(o2); endmodule
