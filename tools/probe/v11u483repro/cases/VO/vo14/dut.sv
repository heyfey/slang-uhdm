// § clsScopedOvRhsRefObj483
class K; parameter logic [3:0] w = 4'hA; endclass
module m #(parameter logic [3:0] A = 4'h1) (output logic [3:0] o); assign o = A; endmodule
module top; logic [3:0] o; m #(.A(K::w)) u(o); endmodule
