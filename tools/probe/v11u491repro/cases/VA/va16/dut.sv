// § ovUnsizedBasedActualForm491
module m #(parameter longint A = 4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A('hFFFF_FFFF)) u(o);
endmodule
