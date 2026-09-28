// § tfArgOutsideClassKeyOrder216v — two files: the outside package p2 (key p2::M before p::K) in its own file, both in one unit
package p2;
  import p::*;
  class M;
    function void h(e_t z); endfunction
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
