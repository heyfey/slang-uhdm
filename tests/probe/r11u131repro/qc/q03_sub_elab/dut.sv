// § pkgQualCallQualSpan131
package p;
  function automatic int f(int a); return a + 1; endfunction
  function automatic int g(); return 3; endfunction
endpackage
module sub #(parameter int A = p::f(2)) ();
endmodule
module top ();
  sub u();
endmodule
