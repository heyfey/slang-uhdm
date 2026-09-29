// § strLitContOwnerEnd224 (a task argument: the call ends at its parenthesis, the literal's owner is the argument only)
module top(input logic c, output string o);
  task automatic t(input string a); o = a; endtask
  always_comb t(c ? "x" : "ab \
cd");
endmodule
