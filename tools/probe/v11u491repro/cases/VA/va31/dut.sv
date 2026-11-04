// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o);
if (A == 5) begin : g assign o = 1; end else begin : h assign o = 0; end
endmodule
module top; logic [7:0] o;
m #(.A('h5)) u(o);
endmodule
