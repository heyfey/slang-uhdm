// § clsScopedOvRhsRefObj483
class K; parameter string nm = "ab"; endclass
module m #(parameter string S = "x") (output logic [7:0] o); assign o = S.len(); endmodule
module top; logic [7:0] o; m #(.S(K::nm)) u(o); endmodule
