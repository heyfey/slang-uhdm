// § unitVarRefMintsNet418
string label = "X";
class C;
  function void f(); $display("%s", label); endfunction
endclass
module top;
  C c;
  initial begin c = new; c.f(); end
endmodule
