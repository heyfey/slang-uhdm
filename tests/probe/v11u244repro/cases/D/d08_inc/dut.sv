// § invalidBlockLocFromSyntax244
`include "body.svh"
package p;
  class base; function base get_comp(); return this; endfunction
    virtual function void pre_read(int a); endfunction endclass
  class obj; endclass
  class pc #(type PORT = obj);
    function void f(PORT x, ref base list[string], base b);
      foreach (list[k]) `BODY2(list, x)
      `CB(b, pre_read(1));
    endfunction
  endclass
endpackage
module top;
endmodule
