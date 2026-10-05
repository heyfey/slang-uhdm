// § cloneStmtHomeVarDupKeyByOrder247
`define INNER \
     int k; \
     k = r; \
     r = k + 1;
`define DO \
   begin \
     `INNER \
   end
package p;
  class fac;
    int r;
    extern task emit();
  endclass
  task fac::emit();
    `DO
    begin
      `INNER
    end
    `DO
  endtask
endpackage
package q;
  import p::*;
  class u;
    function void g();
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
endmodule
