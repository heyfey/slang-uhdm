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
module top;
  import p::*;
  initial emit();
endmodule
