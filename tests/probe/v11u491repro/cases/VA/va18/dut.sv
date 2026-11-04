// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A('d2147483648)) u(o);
endmodule
