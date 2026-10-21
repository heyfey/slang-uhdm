// § caseItemPkgFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
  parameter f_t B = (1<<0);
endpackage
import p::*;
class C;
  function void f(f_t x);
    case (x)
      A: x = 0;
      B: x = 1;
    endcase
  endfunction
endclass
module top; C c; endmodule
