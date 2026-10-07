// § ifaceElabTypeParamIsDefObj278
interface ifc ();
  localparam type T = logic [1:0];
  logic [1:0] x;
endinterface
module top; ifc u(); endmodule
