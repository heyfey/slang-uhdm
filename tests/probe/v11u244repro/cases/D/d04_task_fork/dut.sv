// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
    task go(); endtask
  endclass
  class obj; endclass
  class pc #(type PORT = obj);
    task t(PORT x, ref base list[string]);
      fork
        begin list["a"] = x.get_comp(); end
        begin #1; x.go(); end
      join
      foreach (list[k]) begin
        int n;
        n = 1;
        x.go();
      end
    endtask
  endclass
endpackage
module top;
endmodule
