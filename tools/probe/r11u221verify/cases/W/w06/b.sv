// § tfArgOutsideClassKeyOrder216v — second file of w06 (CRLF)
package zq;
  import p::*;
  class Outer;
    class Inner;
      function void h(e_t z); endfunction
    endclass
  endclass
endpackage
module top;
  import p::*;
  e_t v;
  initial g(v);
endmodule
