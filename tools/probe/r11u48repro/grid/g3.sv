// g3 — a package function body calling another with a PLAIN BODY LOCAL
// (not a loop variable) as the actual.
package g3p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned f(int unsigned n);
    automatic int unsigned k = n;
    return w(k);
  endfunction
endpackage
module g3 (output logic [g3p::f(3)-1:0] o);
  assign o = '0;
endmodule
