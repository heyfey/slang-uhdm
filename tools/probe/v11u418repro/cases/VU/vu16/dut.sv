// § unitVarNestedScopeAbstain418v
string label = "X";
module top;
  class C;
    function void f(); $display("%s", label); endfunction
  endclass
  initial $display("%s", label);
endmodule
