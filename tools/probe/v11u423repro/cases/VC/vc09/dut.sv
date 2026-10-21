// § caseItemPkgFoldTsOps423
package p;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t A = E1;
  typedef logic [3:0] n_t;
  parameter n_t B = 4'd2 * 2;
  parameter n_t C = B + 1;
endpackage
import p::*;
class K;
  function int f(n_t x);
    case (x)
      B: return 1;
      C: return 2;
    endcase
    return 0;
  endfunction
endclass
module top; K k; endmodule
