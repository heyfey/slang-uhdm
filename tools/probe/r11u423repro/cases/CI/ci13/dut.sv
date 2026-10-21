// § caseItemPkgFoldTsOps423 (control: unchanged, already golden)
package p;
  parameter int A = 16;
endpackage
module top;
  import p::*;
  int y;
  initial
    case (y)
      A: y = 0;
    endcase
endmodule
