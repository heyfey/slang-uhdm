// § topPkgTdInstanceTop231 — the package in another file, the typedefs at the same positions as this file's
package q;
  typedef enum {B0, B1} a_e;
  typedef a_e b_t;
  class c;
    extern function void set(b_t v);
  endclass
  function void c::set(b_t v);
  endfunction
endpackage
module top;
  import p::*;
  b_t s;
endmodule
