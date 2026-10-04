// § topPkgTdInstanceTop231 — the typedefs come from a header included in the package
package p;
`include "td.svh"
  class c;
    extern function void set(b_t v);
  endclass
  function void c::set(b_t v);
  endfunction
endpackage
module top;
endmodule
