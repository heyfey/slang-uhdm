// § clsTfOpFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
package q;
  import p::*;
  class C;
    function bit f(f_t x);
      case (x)
        A: return 1;
      endcase
      return x == A;
    endfunction
  endclass
endpackage
module top; q::C c; endmodule
