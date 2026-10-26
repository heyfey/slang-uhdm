// § bodyTypeParamDefKeepsDecl431
interface ifc();
parameter type T = int;
T v;
endinterface
module top();
ifc #(.T(byte)) u ();
endmodule
