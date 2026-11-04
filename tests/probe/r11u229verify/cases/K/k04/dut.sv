// § strLitContOwnerEnd224 (a single-statement initial whose assignment ends at the literal)
module top(input logic c, output string o);
  initial o = c ? "x" : "ab \
cd";
endmodule
