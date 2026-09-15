// g8 — g1's formal-actual shape in a PACKAGE function evaluated from a RANGE
// (g1 is evaluated from a cont_assign): isolates the evaluation context.
package g8p;
  function automatic int unsigned mul2(int unsigned x); return 2 * x; endfunction
  function automatic int unsigned mul4(int unsigned x); return mul2(mul2(x)); endfunction
endpackage
module g8 (output logic [g8p::mul4(1)-1:0] o);
  assign o = '0;
endmodule
