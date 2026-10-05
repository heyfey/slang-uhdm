// § cloneStmtHomeVarDupKeyByOrder247
`define DO(T) \
   begin \
     T v; \
     v = 1; \
     r += v; \
   end
package p;
  class fac;
    int r;
    extern function void emit();
  endclass
  function void fac::emit();
    `DO(int)
    `DO(byte)
    `DO(int)
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
