// § ovSizedActualSize489
module m #(parameter A = 8'd1) (output logic [7:0] o);
always_comb o = A;
endmodule
module top; logic [7:0] o;
m #(.A(4'hF)) u(o);
endmodule
