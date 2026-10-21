// § tpVarInitSizedByDefault424
interface ifc #(parameter type T = shortint);
  T j = 1;
endinterface
module top; ifc #(.T(int)) u(); endmodule
