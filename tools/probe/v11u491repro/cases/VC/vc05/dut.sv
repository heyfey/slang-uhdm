// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o);
for (genvar i = 0; i < A; i++) begin : g assign o[i] = 1'b1; end
endmodule
module top; logic [7:0] o; m #(.A('h5)) u(o); endmodule
