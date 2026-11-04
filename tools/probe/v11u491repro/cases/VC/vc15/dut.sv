// § ovSizedActualMoreBases491
module m #(parameter A = 4'd15) (output logic [7:0] o); for (genvar i = 0; i < A; i++) begin : g end assign o = 0; endmodule
module top; logic [7:0] o; m #(.A(4'b0011)) u(o); endmodule
