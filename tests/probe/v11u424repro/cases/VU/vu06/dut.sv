// § ifcUnitVarRefMintsNet424
int cnt = 1;
interface ifc;
  initial $display("%0d", cnt);
endinterface
module top;
  if (1) begin : g
    ifc u ();
  end
endmodule
