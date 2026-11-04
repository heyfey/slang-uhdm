// § ovUnsizedBasedActualForm491
module m #(parameter shortint A = 4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A('hFFFFF)) u(o);
endmodule
