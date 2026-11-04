// § clsOvExprActualOpTree485
class K; parameter w = 5; endclass
module m #(parameter A = 4) (output logic [7:0] o);
  assign o = 8'd0;
endmodule
module top; logic [7:0] o1, o2; m #(.A(K::w + 1)) u1(o1); m #(.A(K::w * 2)) u2(o2); endmodule
