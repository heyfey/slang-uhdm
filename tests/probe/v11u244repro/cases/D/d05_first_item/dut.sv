// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
    task go(); endtask
  endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void f(PORT x, ref base list[string]);
      list["a"] = x.get_comp();
    endfunction
    function void g(PORT x, ref base list[string]);
      int n;
      foreach (list[k]) list[k] = x.get_comp();
      n = 1;
    endfunction
    function void h(PORT x, ref base list[string]);
      for (int i = 0; i < 2; i++) begin list["i"] = x.get_comp(); end
    endfunction
  endclass
endpackage
module top;
endmodule
