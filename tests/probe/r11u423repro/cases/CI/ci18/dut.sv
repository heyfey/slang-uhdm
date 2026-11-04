// § caseItemPkgFoldTsOps423
package p;
  parameter int A = (1<<4);
endpackage
module top;
  import p::*;
  function void f(int x);
    case (x)
      A: x = 0;
    endcase
  endfunction
endmodule
