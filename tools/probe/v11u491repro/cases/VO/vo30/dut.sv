// § ovSizedActualMoreBases491
module m #(parameter A = 4'd15) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(4'b1010) u(o); m #(4'o3) u2();
endmodule
