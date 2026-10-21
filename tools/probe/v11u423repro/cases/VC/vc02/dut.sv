// § caseItemPkgFoldTsOps423
package p;
  parameter int A = 3 + 4;
  parameter logic [7:0] B = -(2);
  parameter bit C = (1 < 2);
endpackage
module top(input int x, output int y);
  import p::*;
  function automatic int f(int a);
    case (a)
      A: return 1;
      B: return 2;
      C: return 3;
      default: return 0;
    endcase
  endfunction
  assign y = f(x);
endmodule
