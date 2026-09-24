// r10v123 minimal M4 — the CONTROL for M3: a plain (non-chained) typedef.
package rowan123_pkg;
  typedef bit [7:0] rowan_v_t;
  function automatic int rowan_f(int qq);
    return int'(rowan_v_t'(qq));
  endfunction
endpackage
module rowan_top;
  int rr;
  initial rr = rowan123_pkg::rowan_f(3);
endmodule
