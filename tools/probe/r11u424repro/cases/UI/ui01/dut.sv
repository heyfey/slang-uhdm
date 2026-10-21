// § ifcUnitVarRefMintsNet424 (v11u418 VU/vu08)
string label = "X";
interface ifc;
  initial $display("%s", label);
endinterface
module top;
  ifc u ();
  initial $display("%s", label);
endmodule
