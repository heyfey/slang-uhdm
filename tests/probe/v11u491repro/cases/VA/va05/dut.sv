// § ovUnsizedBasedActualForm491
module m #(parameter logic [7:0] A = 4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A('b1_0_1)) u(o);
endmodule
