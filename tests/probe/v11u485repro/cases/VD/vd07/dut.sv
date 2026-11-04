// § clsOvDepParamOpTree485
class K; parameter w = 5; endclass
module m #(parameter A = 4) (output logic [7:0] o);
  localparam B = A + 1;
  assign o = 8'd0;
endmodule
module top; logic [7:0] o1, o2; m #(.A(K::w)) u1(o1); m #(.A(7)) u2(o2); endmodule
