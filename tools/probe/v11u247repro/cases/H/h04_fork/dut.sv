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
module top;
  import p::*;
  fac z;
endmodule
