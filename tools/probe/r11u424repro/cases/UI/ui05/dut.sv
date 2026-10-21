// § ifcUnitVarRefMintsNet424
int cnt = 3;
interface ifc(output int o);
  assign o = cnt;
  always_comb if (cnt > 2) $display("big");
endinterface
module top;
  int o;
  ifc u (o);
endmodule
