// § clsOvDefparamAbstain483v
class K; parameter w = 3; endclass
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid (output logic [7:0] o); m #(.A(K::w)) u(o); endmodule
module top; logic [7:0] o; mid x(o); defparam x.u.A = 7; endmodule
