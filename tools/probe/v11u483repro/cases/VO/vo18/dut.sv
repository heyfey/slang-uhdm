// § clsOvDefparamAbstain483v
class K; parameter w = 3; endclass
module m #(parameter A = 4, parameter B = 2) (output logic [7:0] o); assign o = A + B; endmodule
module top; logic [7:0] o; m #(.A(K::w)) u(o); defparam u.B = 6; endmodule
