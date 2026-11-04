// § topPkgTdInstanceTop231 — typedefs and the prototype written by macros
`define TD(t, n) typedef t n;
`define PROTO(n) extern function void set(n v);
package p;
  typedef enum {A0, A1} a_e;
  `TD(a_e, b_t)
  class c;
    `PROTO(b_t)
  endclass
  function void c::set(b_t v);
  endfunction
endpackage
module top;
endmodule
