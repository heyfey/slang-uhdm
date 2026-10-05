// § cloneStmtHomeVarDupKeyByOrder247
`define DO \
   begin \
     int k; \
     k = r; \
     r = k + 1; \
   end
package p;
  int r;
  function void emit();
    `DO
    `DO
  endfunction
  task temit();
    `DO
    `DO
  endtask
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
  initial emit();
endmodule
