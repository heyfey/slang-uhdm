// § ovSizedActualMoreBases491
module m #(parameter A = 4'd15) (output logic [7:0] o);
logic [7:0] r; always_comb r = A; assign o = r;
endmodule
module top; logic [7:0] o;
m #(.A(8'b0000_1010)) u(o);
endmodule
