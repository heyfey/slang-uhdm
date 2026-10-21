// § ifcUnitVarRefMintsNet424
int cnt = 1;
interface ifc(input bit clk);
  logic a;
  always @(posedge clk) a <= cnt[0];
endinterface
module top; bit c; ifc u (c); endmodule
