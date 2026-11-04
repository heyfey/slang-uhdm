// § topPkgTdInstanceTop231 — alias of a struct typedef on an extern method formal
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  typedef s_t s2_t;
  class c;
    extern function void set(s2_t v);
  endclass
  function void c::set(s2_t v);
  endfunction
endpackage
module top;
endmodule
