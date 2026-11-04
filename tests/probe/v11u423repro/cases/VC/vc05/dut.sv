// § clsTfOpFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
import p::*;
class C #(int N = 2);
  function bit f(f_t x);
    case (x)
      A: return 1;
    endcase
    return (x & A) != 0;
  endfunction
endclass
module top; C #(3) c; endmodule
