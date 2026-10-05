// § cloneStmtHomeVarDupKeyByOrder247
`define DO \
   begin \
     int k; \
     k = r; \
     r = k + 1; \
   end
package p;
  class fac;
    int r;
    extern task emit();
  endclass
  task fac::emit();
    fork
      `DO
      `DO
    join
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
  fac z;
endmodule
