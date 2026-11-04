// § ovSizedActualSize489
module m #(parameter A = 4'd15) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
m #(.A(4'sd3)) u(o);
endmodule
