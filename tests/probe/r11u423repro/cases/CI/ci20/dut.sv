// § caseItemPkgFoldTsOps423 (control: unchanged, already golden)
package p;
  parameter bit [27:0] A = 16;
endpackage
module top;
  import p::*;
  function void f(int x);
    case (x)
      A: x = 0;
    endcase
  endfunction
endmodule
