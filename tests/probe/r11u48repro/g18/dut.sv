// g18 — g14's never-evaluated shape with the call inside an IF (no loop): the
// NEGATIVE control for the loop term.
package g18p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic bit f(int unsigned n);
    automatic int unsigned r = 0;
    automatic int unsigned k = 1;
    if (n > 0) r = w(k);
    return r != 0;
  endfunction
endpackage
module g18 (input logic c, output logic o);
  assign o = c;
endmodule
