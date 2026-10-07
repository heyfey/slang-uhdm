// § ifaceElabTypeParamIsDefObj278
interface ifc ();
  localparam type T = logic [1:0];
  T x;
endinterface
module top; ifc u(); endmodule
