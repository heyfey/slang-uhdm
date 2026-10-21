// § ifcUnitVarRefMintsNet424
int cnt = 3;
interface ifc;
  logic [7:0] q;
  always_comb q = cnt;
endinterface
module top; ifc u (); endmodule
