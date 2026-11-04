// § ovUnsizedBasedActualForm491
module m #(parameter logic signed [7:0] A = 4) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A('hFF)) u(o);
endmodule
