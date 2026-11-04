// § clsTfOpFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
import p::*;
class C;
  function void f(f_t x);
    if (x == A) x = 0;
  endfunction
endclass
module top; C c; endmodule
