// § ifcUnitVarRefMintsNet424
string label = "X";
interface ifc;
  initial $display("%s", label);
endinterface
module top;
  ifc u1 ();
  ifc u2 ();
endmodule
