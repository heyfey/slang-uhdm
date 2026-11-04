// § ovSizedActualMoreBases491
module m #(parameter A = 4'd15) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A(17'b1_0101_0101_0101_0101)) u(o);
endmodule
