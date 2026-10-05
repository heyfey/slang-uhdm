// § cloneStmtHomeVarRef17
package p;
  class it;
    function it first(); return this; endfunction
    function it next(); return null; endfunction
  endclass
  class fac;
    extern task emit();
  endclass
  task fac::emit();
    int k;
    k = 1;
    begin
      it iter = new();
      it cb = iter.first();
      while (cb != null) cb = iter.next();
    end
  endtask
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
