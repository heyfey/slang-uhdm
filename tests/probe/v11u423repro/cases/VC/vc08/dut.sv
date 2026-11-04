// § caseItemPkgFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
module sub(input logic [27:0] x, output bit o);
  import p::*;
  function automatic bit f(f_t v);
    case (v)
      A: return 1;
    endcase
    return v > A;
  endfunction
  assign o = f(x);
endmodule
module top(input logic [27:0] x, output bit o1, output bit o2);
  sub u1(.x(x), .o(o1));
  sub u2(.x(x), .o(o2));
endmodule
