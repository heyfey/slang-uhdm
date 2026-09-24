// § pkgQualCallQualSpan131
package p;
  function automatic int f(int x); return x * 2; endfunction
endpackage
module top ();
  localparam int P = (p::f(1)) + 1;
endmodule
