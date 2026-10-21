// § caseItemPkgFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
package q;
  typedef bit [7:0] g_t;
  parameter g_t A = (1<<2);
endpackage
import q::A;
import q::g_t;
class C;
  function void f(g_t x);
    case (x)
      A: x = 0;
    endcase
  endfunction
endclass
module top(output logic [27:0] v);
  import p::*;
  assign v = A;
  C c;
endmodule
