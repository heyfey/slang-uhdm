// va5 — a FORMAL argument passed on in the return expression (golden STAMPS;
// must stay stamped: FormalArgumentSymbol is not SymbolKind::Variable).
package va5p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned f(int unsigned n);
    return w(n) + 1;
  endfunction
endpackage
module va5 (input logic c, output logic o);
  assign o = c;
endmodule
