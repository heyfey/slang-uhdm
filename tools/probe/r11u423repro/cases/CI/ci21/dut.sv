// § caseItemFoldClassOwner423
package p;
  parameter int A = (1<<4);
  parameter bit [27:0] B = (1<<0);
endpackage
import p::*;
class C;
  function void f(int x);
    case (x)
      A: x = 0;
      B: x = 1;
    endcase
  endfunction
endclass
module top; C c; endmodule
