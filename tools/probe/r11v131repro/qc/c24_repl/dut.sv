// § pkgQualCallQualSpan131
package p;
  function automatic int f(int x); return x * 2; endfunction
endpackage
module top ();
  localparam logic [63:0] P = {2{p::f(1)}};
endmodule
