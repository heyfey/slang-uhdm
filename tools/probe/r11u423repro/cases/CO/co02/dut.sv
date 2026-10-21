// § clsTfOpFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t ALL = 'b000000101010101;
  parameter f_t NOCOPY = (1<<1);
endpackage
import p::*;
class C;
  function bit f(f_t w);
    return (!((ALL & w) & NOCOPY));
  endfunction
endclass
module top; C c; endmodule
