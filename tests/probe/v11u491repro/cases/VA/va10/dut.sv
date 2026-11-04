// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A('O17)) u(o);
endmodule
