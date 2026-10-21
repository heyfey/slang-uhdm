// § ifcUnitVarRefMintsNet424
string label = "X";
interface ifc;
  task t; string label; label = "y"; endtask
  initial $display("%s", label);
endinterface
module top; ifc u (); endmodule
