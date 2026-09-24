// vc5 — the FORMAL (not a body local) in the IF-condition call: golden STAMPS
// formals; the guard must not reach it.
package vc5p;
  function automatic int unsigned fw(int unsigned i); return i + 1; endfunction
  function automatic int unsigned g(int unsigned n);
    automatic int unsigned res = 0;
    if (fw(n) > res) res = fw(n);
    return res;
  endfunction
endpackage
module vc5 (output logic [vc5p::g(3)-1:0] b);
  assign b = '0;
endmodule
