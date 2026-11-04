// § ifcUnitVarRefMintsNet424
string label = "X";
interface ifc;
  if (1) begin : g
    initial $display("%s", label);
  end
endinterface
module top;
  ifc u ();
endmodule
