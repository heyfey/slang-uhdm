// § ifcUnitVarRefMintsNet424
int cnt = 1;
interface ifc;
  logic a;
  initial a = cnt;
  modport mp(input a);
endinterface
module sub(ifc.mp p); endmodule
module top; ifc u (); sub s(u); endmodule
