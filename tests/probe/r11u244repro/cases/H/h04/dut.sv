// § cloneStmtHomeVarRef17
package p;
  class it;
    function it first(); return this; endfunction
    function it next(); return null; endfunction
  endclass
  class fac;
    extern function void emit();
  endclass
  function void fac::emit();
    begin
      it iter = new();
      it cb = iter.first();
      while (cb != null) cb = iter.next();
    end
    begin
      it iter = new();
      it cb = iter.first();
      while (cb != null) cb = iter.next();
    end
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void f();
      fac x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  fac z;
  u w;
  initial w = new();
endmodule
