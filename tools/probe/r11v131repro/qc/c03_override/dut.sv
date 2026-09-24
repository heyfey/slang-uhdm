// § pkgQualCallQualSpan131
package p;
  function automatic int f(int x); return x * 2; endfunction
endpackage
module sub #(parameter int W = 1) ();
endmodule
module top ();
  sub #(.W(p::f(3))) u();
endmodule
