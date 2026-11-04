// § ifcUnitVarRefMintsNet424
int cnt = 1;
interface ifc;
  logic a;
  initial a = cnt;
endinterface
module top; ifc u [1:0] (); endmodule
