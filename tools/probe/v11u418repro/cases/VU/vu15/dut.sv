// § unitVarNestedScopeAbstain418v
string label = "X";
module top;
  generate
    initial $display("%s", label);
  endgenerate
endmodule
