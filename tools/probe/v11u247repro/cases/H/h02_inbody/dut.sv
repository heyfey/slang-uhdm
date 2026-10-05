// § cloneStmtHomeVarDupKeyByOrder247
`define DO \
   begin \
     int k = 0; \
     k++; \
     r += k; \
   end
package p;
  class fac;
    int r;
    function void emit();
      `DO
      if (r > 0) begin
        `DO
      end
    endfunction
  endclass
  function int pf();
    int r;
    `DO
    `DO
    return r;
  endfunction
endpackage
module top;
  import p::*;
  fac z;
  int q;
  initial q = pf();
endmodule
