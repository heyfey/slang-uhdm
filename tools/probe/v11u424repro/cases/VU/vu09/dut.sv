// § ifcUnitVarRefMintsNet424
logic g = 1'b1;
interface ifc;
  logic a;
  initial a = g;
endinterface
module m; ifc u (); endmodule
module top; m mm (); ifc v (); endmodule
