// va9 — a body local passed to a NESTED call inside the return expression
// (w(g(k)) — k is the inner call's actual, not the top call's).
package va9p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned g(int unsigned i); return i + 2; endfunction
  function automatic int unsigned f(int unsigned n);
    int unsigned k = n;
    return w(g(k));
  endfunction
endpackage
module va9 (input logic c, output logic o);
  assign o = c;
endmodule
