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
module top;
  import p::*;
  fac z;
endmodule
