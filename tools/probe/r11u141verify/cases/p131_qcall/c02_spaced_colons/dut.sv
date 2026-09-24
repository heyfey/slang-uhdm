// § pkgQualCallQualSpan131
// case c02: package-qualified call written with spaces around the ::
package p;
  function automatic int f(int a);
    return a + 1;
  endfunction
endpackage
module sub #(parameter int P = p :: f(2)) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
