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
    begin
      it iter;
      it cb;
      iter = new();
      cb = iter.first();
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
