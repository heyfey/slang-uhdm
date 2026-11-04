// § clsOvDepParamOpTree485
class K; parameter w = 5; endclass
interface ifc #(parameter A = 4); localparam B = A + 1; logic a; endinterface
module top; ifc #(.A(K::w)) u(); endmodule
