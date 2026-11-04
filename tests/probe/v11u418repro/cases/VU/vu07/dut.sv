// § unitVarNestedScopeAbstain418v
string label = "X";
module top;
  class C;
    function void f(); $display("%s", label); endfunction
  endclass
  initial begin C c = new; c.f(); end
endmodule
