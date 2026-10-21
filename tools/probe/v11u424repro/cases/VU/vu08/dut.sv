// § ifcUnitVarRefMintsNet424
int cnt = 1;
interface ifc;
  logic a;
  initial begin
    int cnt;
    cnt = 2;
  end
  initial $display("%0d", cnt);
endinterface
module top; ifc u (); endmodule
