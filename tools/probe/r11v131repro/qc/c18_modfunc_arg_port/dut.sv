// § constCtxCallArgInner131v
package p;
  function automatic int f(int x); return x * 2; endfunction
endpackage
module sub #(parameter int W = 1) ();
  function automatic int lf(int x); return x + 1; endfunction
  localparam int P = lf(p::f(W));
endmodule
module top ();
  sub #(.W(2)) u();
endmodule
