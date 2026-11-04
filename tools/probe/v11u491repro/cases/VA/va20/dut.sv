// § ovUnsizedBasedActualForm491
module m #(parameter A = 8'hF) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A('h5)) u(o);
endmodule
