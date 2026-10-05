// § invalidBlockLocFromSyntax244
`define BODY(L, X) begin L["m"] = X.get_comp(); end
package p;
  class base; function base get_comp(); return this; endfunction endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void f(PORT x, ref base list[string]);
      foreach (list[k]) `BODY(list, x)
      if (1) `BODY(list, x)
    endfunction
  endclass
endpackage
module top;
endmodule
