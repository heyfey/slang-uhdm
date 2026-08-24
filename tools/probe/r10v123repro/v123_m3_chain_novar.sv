// r10v123 minimal M3 — the alias-of-alias cast with NO variable of that type,
// so LAW S's ref_var head cannot mask the cast cell from the official judge.
package quince123_pkg;
  typedef bit [7:0] quince_base_t;
  typedef quince_base_t quince_mid_t;
  function automatic int quince_f(int qq);
    return int'(quince_mid_t'(qq));
  endfunction
endpackage
module quince_top;
  int rr;
  initial rr = quince123_pkg::quince_f(3);
endmodule
