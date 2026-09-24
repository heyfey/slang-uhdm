// § constCtxCallArgInner131v
package p;
  function automatic int f(int x); return x * 2; endfunction
endpackage
module top ();
  function automatic int lf(int x); return x + 1; endfunction
  localparam int P = lf(p::f(1));
endmodule
