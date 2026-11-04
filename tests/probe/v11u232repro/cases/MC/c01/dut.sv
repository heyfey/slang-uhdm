// § cloneRetNoMintBindsHome232
// class methods assigning the return name: a bit select, inc, a call index; an extern body below; used through an import
package pk;
  class base;
    virtual function int f(int a); endfunction
  endclass
  class C extends base;
    int q[4];
    function int g(int a);
      g = a;
      g[1] = 1'b1;
      g++;
      g[$size(q)-1] = 1'b0;
    endfunction
    extern function int h(int a);
    virtual function int f(int a);
      f = h(a) + g(a);
    endfunction
  endclass
  function int C::h(int a);
    h = a * 2;
    h--;
  endfunction
endpackage
module top(output int o);
  import pk::*;
  C c;
  initial begin
    c = new;
    o = c.f(3);
  end
endmodule
