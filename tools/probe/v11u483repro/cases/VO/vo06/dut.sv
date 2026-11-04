// § clsScopedOvRhsRefObj483
class K; parameter w = 5; parameter v = 6; endclass
module m #(parameter A = 4, parameter B = 3) (output logic [7:0] o); assign o = A + B; endmodule
module top; logic [7:0] o; m #(.B(K::v), .A(K::w)) u(o); endmodule
