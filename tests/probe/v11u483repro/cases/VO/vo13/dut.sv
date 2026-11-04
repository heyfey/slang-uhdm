// § clsOvDefparamAbstain483v
class K; parameter w = 3; endclass
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.A(K::w)) u(o); defparam u.A = 6; endmodule
