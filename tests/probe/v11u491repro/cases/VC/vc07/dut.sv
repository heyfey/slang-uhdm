// § ovUnsizedBasedActualForm491
module m #(parameter int unsigned A = 4) (output logic [7:0] o); always_comb o = A; endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
