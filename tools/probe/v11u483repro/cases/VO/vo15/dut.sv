// § clsScopedOvRhsRefObj483
class K; parameter w = 3; endclass
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid #(parameter P = 1) (output logic [7:0] o); m #(.A(K::w)) u(o); endmodule
module top; logic [7:0] o1, o2; mid #(1) a(o1); mid #(2) b(o2); endmodule
