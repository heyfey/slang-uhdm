// § ovUnsizedBasedActualForm491
module m #(parameter real A = 1.0) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A('h5)) u(o);
endmodule
