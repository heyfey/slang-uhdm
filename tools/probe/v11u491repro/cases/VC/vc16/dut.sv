// § ovSizedActualMoreBases491
module m #(parameter A = 4'd15, parameter B = A) (output logic [7:0] o); assign o = B; endmodule
module top; logic [7:0] o; m #(.A(4'b1010)) u(o); endmodule
