// § invalidBlockLocFromSyntax244
package p;
  class base;
    function base get_comp(); return this; endfunction
    task go(); endtask
  endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void f(PORT x, ref base list[string], input int c);
      case (c)
        0: begin list["a"] = x.get_comp(); end
        default: begin
          base t;
          t = x.get_comp();
          list["d"] = t;
        end
      endcase
    endfunction
  endclass
endpackage
module top;
endmodule
