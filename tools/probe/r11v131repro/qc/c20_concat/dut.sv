// § pkgQualCallQualSpan131
package p;
  function automatic int f(int x); return x * 2; endfunction
endpackage
module top ();
  localparam logic [63:0] P = {p::f(1), p::f(2)};
endmodule
