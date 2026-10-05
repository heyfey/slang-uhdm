// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
    task go(); endtask
  endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void f(PORT x, ref base list[string], input bit c);
      if (c) begin
        list["a"] = x.get_comp();
      end
      else begin
        list["b"] = x.get_comp();
      end
    endfunction
  endclass
endpackage
module top;
endmodule
