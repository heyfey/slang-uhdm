// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
    task go(); endtask
  endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void f(PORT x, ref base list[string], input int c);
      while (c > 0) begin
        list["a"] = x.get_comp();
        c--;
      end
      repeat (2) begin list["r"] = x.get_comp(); end
      do begin list["d"] = x.get_comp(); end while (0);
    endfunction
  endclass
endpackage
module top;
endmodule
