// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  function automatic int f(int a); return a + 1; endfunction
  localparam X = 8'(f(W));
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
