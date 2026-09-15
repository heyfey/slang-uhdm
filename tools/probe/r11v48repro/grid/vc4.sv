// vc4 — a loop local in an IF CONDITION call, and the SAME local also passed in
// the RETURN expression, package function constant-evaluated.
package vc4p;
  function automatic int unsigned fw(int unsigned i); return i + 1; endfunction
  function automatic int unsigned maxw(int unsigned n);
    automatic int unsigned res = 0;
    automatic int unsigned last = 0;
    for (int unsigned i = 0; i < n; i++) begin
      if (fw(i) > res) res = fw(i);
      last = i;
    end
    return fw(last);
  endfunction
endpackage
module vc4 (output logic [vc4p::maxw(3)-1:0] b);
  assign b = '0;
endmodule
