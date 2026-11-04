// § caseItemPkgFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
module top;
  import p::*;
  function void f(f_t x);
    case (x)
      A: x = 0;
    endcase
  endfunction
endmodule
