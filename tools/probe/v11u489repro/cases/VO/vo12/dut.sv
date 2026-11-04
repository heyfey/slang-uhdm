// § ovSizedActualSize489
module m #(parameter A = 4'hF) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A(4'h0)) u(o);
endmodule
