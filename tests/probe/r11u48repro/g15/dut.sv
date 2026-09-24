// g15 — g14 with the local declared in a FOR-LOOP HEADER (cfg's shape) and the
// same never-evaluated package.
package g15p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic bit f(int unsigned n);
    automatic int unsigned r = 0;
    for (int unsigned i = 0; i < n; i++) r = w(i);
    return r != 0;
  endfunction
endpackage
module g15 (input logic c, output logic o);
  assign o = c;
endmodule
