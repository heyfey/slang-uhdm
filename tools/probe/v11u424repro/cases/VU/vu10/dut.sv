// § ifcUnitVarRefMintsNet424
int cnt = 1;
interface ifc(input bit clk);
  logic a;
  assert property (@(posedge clk) cnt > 0);
endinterface
module top; bit c; ifc u (c); endmodule
