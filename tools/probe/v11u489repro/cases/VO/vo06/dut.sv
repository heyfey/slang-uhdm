// § ovSizedActualSize489
module m #(parameter A = 4'd15) (output logic [7:0] o);
assign o = A;
endmodule
module top; logic [7:0] o;
logic [7:0] o2; m #(.A(4'd3)) u1(o); m #(.A(6'd3)) u2(o2);
endmodule
