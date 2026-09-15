// g21 — a never-evaluated MODULE function with the call inside a for loop
// (the module-scope twin of g15).
module g21 (input logic c, output logic o);
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic bit f(int unsigned n);
    automatic int unsigned r = 0;
    for (int unsigned i = 0; i < n; i++) r = w(i);
    return r != 0;
  endfunction
  assign o = c;
endmodule
