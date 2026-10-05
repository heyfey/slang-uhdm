// § cloneStmtHomeVarRef17
package p;
  class it #(type T = int, type CB = int);
    function new(T o); endfunction
    function CB first(); return null; endfunction
    function CB next(); return null; endfunction
  endclass
  class cbk; endclass
  class fac;
    extern task emit();
  endclass
  task fac::emit();
    int k;
    k = 1;
    begin
      it#(fac,cbk) iter = new(this);
      cbk cb = iter.first();
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
