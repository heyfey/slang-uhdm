// § topPkgTdInstanceTop231 — a package importing another package's alias
package p;
  typedef enum {A0, A1} a_e;
  typedef a_e b_t;
endpackage
package q;
  import p::*;
  class c;
    extern function void set(b_t v);
  endclass
  function void c::set(b_t v);
  endfunction
endpackage
module top;
  import q::*;
endmodule
