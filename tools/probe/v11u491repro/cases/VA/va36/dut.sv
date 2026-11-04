// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o[2];
for (genvar g = 0; g < 2; g++) begin : gb m #(.A('h5)) u(o[g]); end
endmodule
