// § clsScopedOvRhsRefObj483
class K; parameter w = 3; endclass
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o;
  module inner (output logic [7:0] q); m #(.A(K::w)) u(q); endmodule
  inner i1(o);
endmodule
