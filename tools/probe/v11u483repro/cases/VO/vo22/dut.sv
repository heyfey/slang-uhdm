// § clsScopedOvRhsRefObj483
class B; parameter w = 3; endclass
class K extends B; endclass
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.A(K::w)) u(o); endmodule
