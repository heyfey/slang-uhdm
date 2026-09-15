// va1 — MIXED: a package function with a loop-local arg (must go BARE) and a
// return-expression local arg (must STAY stamped) in ONE never-evaluated body.
package va1p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned g(int unsigned i); return i + 2; endfunction
  function automatic int unsigned f(int unsigned n);
    int unsigned s = 0;
    for (int unsigned i = 0; i < n; i++) s = s + w(i);
    return g(s) + 1;
  endfunction
endpackage
module va1 (input logic c, output logic o);
  assign o = c;
endmodule
