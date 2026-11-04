// § unitVarRefMintsNet418
string label = "X";
program prg;
  initial $display("%s", label);
endprogram
module top;
  initial $display("%s", label);
endmodule
