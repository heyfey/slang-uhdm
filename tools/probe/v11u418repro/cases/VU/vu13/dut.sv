// § unitVarNestedScopeAbstain418v
string label = "X";
module top #(parameter N = 1);
  if (N == 1) initial $display("%s", label);
endmodule
