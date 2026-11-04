// § clsScopedOvRhsRefObj483
class K; parameter w = 3; endclass
module m #(parameter A = 4, localparam B = A) (output logic [7:0] o); assign o = B; endmodule
module top; logic [7:0] o; m #(.A(K::w)) u(o); endmodule
