// V2 — the '::' joint at PACKAGE scope: a package function whose part-select
// bound is a local (non-constant) — law 2's separator regime outside a class.
package v2_pkg;
  int unsigned aq[$];
  logic [31:0] pvec;
  function automatic int fslice(int b);
    int unsigned t[$];
    t = aq[0:b-1];
    return t.size();
  endfunction
  function automatic logic [7:0] fidx(int k);
    return pvec[k +: 8];
  endfunction
  function automatic int unsigned fsim(int k);
    int unsigned t[$];
    t = aq[k:k+2];          // QUEUE slice, BOTH bounds non-constant
    return t.size();
  endfunction
endpackage
module v2_pkg_top;
  int z; logic [7:0] y0; int unsigned y1;
  initial begin z = v2_pkg::fslice(3); y0 = v2_pkg::fidx(4); y1 = v2_pkg::fsim(2); end
endmodule
