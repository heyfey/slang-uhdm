// § caseItemPkgFoldTsOps423 (control: unchanged, already golden)
package p;
  parameter int A = 16;
endpackage
module top;
  import p::*;
  function void f(int x);
    case (x)
      A: x = 0;
    endcase
  endfunction
endmodule
