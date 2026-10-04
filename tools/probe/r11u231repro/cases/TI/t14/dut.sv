// § topPkgTdInstanceTop231 — alias on a package function formal and a package variable (no class)
package p;
  typedef enum {A0, A1} a_e;
  typedef a_e b_t;
  function automatic int f(b_t v);
    return int'(v);
  endfunction
endpackage
module top(output int o);
  assign o = p::f(p::A1);
endmodule
