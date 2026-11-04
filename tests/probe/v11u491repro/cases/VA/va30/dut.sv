// § ovUnsizedBasedActualForm491
module m #(parameter A = 4) (output logic [7:0] o);
initial $display(A); assign o = 0;
endmodule
module top; logic [7:0] o;
m #(.A('h5)) u(o);
endmodule
