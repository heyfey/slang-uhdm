// § clsOvExprActualOpTree485
class K; parameter w = 5; endclass
interface ifc #(parameter A = 4) (); logic a; endinterface
module top; ifc #(.A(K::w + 1)) u(); endmodule
