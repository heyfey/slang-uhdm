// § clsScopedOvRhsRefObj483
class K; parameter w = 3; endclass
interface ifw #(parameter W = 4); logic [W-1:0] a; endinterface
module mid #(parameter P = 1) (output logic [7:0] o); ifw #(.W(K::w)) i(); assign o = P; endmodule
module top; logic [7:0] o1, o2; mid #(1) a(o1); mid #(2) b(o2); endmodule
