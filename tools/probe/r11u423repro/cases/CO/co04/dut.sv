// § clsTfOpFoldTsLate423 (control: a module function's operand, not reached)
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
import p::*;
module top;
  function bit f(f_t x);
    return x == A;
  endfunction
endmodule
