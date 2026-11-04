// § unitVarRefMintsNet418
string label = "X";
interface ifc;
  initial $display("%s", label);
endinterface
module top;
  ifc u ();
  initial $display("%s", label);
endmodule
