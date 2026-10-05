// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
    task go(); endtask
  endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void f(PORT x, ref base list[string], ref base l2[string][int]);
      foreach (l2[a, b]) begin
        foreach (list[k]) begin
          list[k] = x.get_comp();
        end
      end
      foreach (list[k])
        list[k] = x.get_comp();
    endfunction
  endclass
endpackage
module top;
endmodule
