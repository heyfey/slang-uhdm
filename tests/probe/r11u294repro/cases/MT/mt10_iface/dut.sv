// § castModTypeParamDefaultTs294
// an interface type parameter
interface ifc #(parameter type T = logic [7:0]) ();
  logic [3:0] a; T y;
  always_comb y = T'(a);
endinterface
module top; ifc i(); endmodule
