// § clsOvDefparamAbstain483v
class K; parameter w = 3; endclass
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o1, o2; m #(.A(K::w)) u1(o1); m u2(o2); defparam u2.A = 6; endmodule
