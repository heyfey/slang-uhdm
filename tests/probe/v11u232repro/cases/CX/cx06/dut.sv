// § cloneRetNoMintBindsHome232
// a pure virtual prototype above, an extern body below the caller, a this. call through the return name
package p1;
  virtual class b;
    pure virtual function int f(int a);
  endclass
  class c extends b;
    function int g(int x);
      g = this.f(x);
      g = g + 1;
    endfunction
    extern virtual function int f(int a);
  endclass
  function int c::f(int a);
    f = a;
    f = f + g(0);
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
