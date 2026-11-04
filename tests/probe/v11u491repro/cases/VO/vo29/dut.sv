// § ovSizedActualMoreBases491
module m #(parameter A = 4'd15) (output logic [7:0] o); assign o = A; endmodule
module mid(output logic [7:0] o); m #(.A(4'b1010)) u(o); endmodule
module top; logic [7:0] o; mid x(o); endmodule
