// § pkgQualCallQualSpan131
package p;
  function automatic int f(int x); return x * 2; endfunction
  function automatic int g(int x); return x + 3; endfunction
endpackage
module top ();
  localparam int P = p::f(1) * 2;
endmodule
