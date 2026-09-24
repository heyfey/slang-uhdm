// § constCtxCallArgInner131v
package p;
  function automatic int f(int x); return x * 2; endfunction
  function automatic int g(int x); return x + 3; endfunction
endpackage
module sub #(parameter int W = $clog2(p::f(3))) ();
endmodule
module top ();
  sub u();
endmodule
