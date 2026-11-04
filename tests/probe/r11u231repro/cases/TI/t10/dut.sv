// § topPkgTdInstanceTop231 — two packages, each an alias shape
package p1;
  typedef enum {A0, A1} a_e;
  typedef a_e b_t;
  class c;
    extern function void set(b_t v);
  endclass
  function void c::set(b_t v);
  endfunction
endpackage
package p2;
  typedef enum {B0, B1, B2} a_e;
  typedef a_e b_t;
  class c;
    extern function void set(b_t v);
  endclass
  function void c::set(b_t v);
  endfunction
endpackage
module top;
endmodule
