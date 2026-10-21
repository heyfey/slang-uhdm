// residue (no law landed): see README
package p;
  typedef logic [7:0] f_t;
  parameter f_t A = 8'h10;
  typedef enum {X, Y} e_t;
  parameter e_t E = Y;
endpackage
import p::*;
class C;
  function void f(int x);
    case (x)
      A: x = 0;
      E: x = 1;
    endcase
  endfunction
endclass
module top; C c; endmodule
