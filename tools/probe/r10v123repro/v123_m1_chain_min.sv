// r10v123 minimal M1 — ONE alias-of-alias cast, nothing else, so the OFFICIAL
// uhdm-cmp line count is a meaningful before/after measurement.
package olive123_pkg;
  typedef bit [7:0] olive_base_t;
  typedef olive_base_t olive_mid_t;
  function automatic int olive_f(int qq);
    olive_mid_t mm;
    mm = olive_mid_t'(qq);
    return int'(mm);
  endfunction
endpackage
module olive_top;
  int rr;
  initial rr = olive123_pkg::olive_f(3);
endmodule
