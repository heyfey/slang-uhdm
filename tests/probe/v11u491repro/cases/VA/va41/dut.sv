// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid #(parameter P = 1) (output logic [7:0] o); m #(.A('h5)) u(o); endmodule
module top; logic [7:0] o; mid #(.P(2)) x(o); endmodule
