// residue (no law landed): see README
package p;
  parameter A = 16;
  parameter int B = 1;
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
