// § cloneStmtHomeVarDupKeyByOrder247
package p;
  class fac;
    int r;
    extern function void emit();
  endclass
  function void fac::emit();
    begin
      `include "a.svh"
    end
    begin
      `include "b.svh"
    end
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void g();
      int x;
      x = 0;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w;
  fac z;
endmodule
