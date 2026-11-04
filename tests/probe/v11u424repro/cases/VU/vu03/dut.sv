// § ifcUnitVarRefMintsNet424
string label = "X";
interface ifc;
  initial $display("%s", label);
endinterface
module a; ifc u (); endmodule
module top; a a1 (); a a2 (); endmodule
