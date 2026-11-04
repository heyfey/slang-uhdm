// § ovUnsizedBasedActualForm491
module m #(parameter A = 4'd3) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A('hAb)) u(o);
endmodule
