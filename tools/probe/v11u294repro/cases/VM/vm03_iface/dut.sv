// § castModTypeParamDefaultTs294
// a cast to an interface type parameter
interface ifc #(parameter type T = logic [5:0]); logic [3:0] a; T y; assign y = T'(a); endinterface
module top; ifc i0 (); endmodule
