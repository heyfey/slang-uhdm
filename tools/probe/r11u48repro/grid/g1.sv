// g1 — NestedCallsOfTheSameFunction shape (golden POSITIVE, measured):
// a package function body calling another with its OWN FORMAL as the actual.
package g1p;
  function automatic int mul2(int x); return 2 * x; endfunction
  function automatic int mul4(int x); return mul2(mul2(x)); endfunction
endpackage
module g1 (output int o);
  assign o = g1p::mul4(1);
endmodule
