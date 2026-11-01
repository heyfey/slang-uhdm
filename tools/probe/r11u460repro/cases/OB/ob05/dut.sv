// § oobCopyCallBindsBodyHomeClone460 (control: callee homed in the class's package)
package q;
  function int f(int a); int cs; cs = a; return cs; endfunction
  class C;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v); endfunction
endpackage
package s;
  import q::*;
  class D extends C;
    function int h(); return g(); endfunction
  endclass
endpackage
module top;
  import s::*;
  D d;
  initial begin d = new; $display(d.h()); end
endmodule
