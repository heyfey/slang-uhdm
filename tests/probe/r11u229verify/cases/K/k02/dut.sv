// § strLitContOwnerEnd224 (a literal continued over three lines, the last operand of a conditional)
module top(input logic c, output string o);
  always_comb o = c ? "x" : "ab \
cd \
ef";
endmodule
