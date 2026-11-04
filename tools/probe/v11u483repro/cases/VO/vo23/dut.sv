// § clsScopedOvRhsRefObj483
class K; parameter w = 3; endclass
interface ifw #(parameter W = 4) (input logic c); logic [W-1:0] a; endinterface
module m (ifw p); endmodule
module top; logic c; ifw #(.W(K::w)) i(c); m mm(i); endmodule
