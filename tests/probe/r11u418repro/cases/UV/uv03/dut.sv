// § unitVarRefMintsNet418
string label = "X";
module sub;
  initial $display("%s", label);
endmodule
module top;
  sub u ();
  initial $display("%s %s", label, label);
endmodule
