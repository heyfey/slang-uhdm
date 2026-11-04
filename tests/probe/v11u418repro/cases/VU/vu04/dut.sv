// § unitVarNestedScopeAbstain418v
string label = "X";
module top;
  if (1) begin : g
    initial $display("%s", label);
  end
endmodule
