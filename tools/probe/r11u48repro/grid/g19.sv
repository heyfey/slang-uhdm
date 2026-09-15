// g19 — g14's never-evaluated shape with the call inside a FOREACH loop.
package g19p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic bit f(int unsigned n);
    automatic int unsigned r = 0;
    automatic int unsigned a [3];
    foreach (a[j]) r = w(a[j]);
    return r != 0;
  endfunction
endpackage
module g19 (input logic c, output logic o);
  assign o = c;
endmodule
