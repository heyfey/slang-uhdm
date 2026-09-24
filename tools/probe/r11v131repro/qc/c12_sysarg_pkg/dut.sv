// § constCtxCallArgInner131v
package p;
  function automatic int f(int x); return x * 2; endfunction
  function automatic int g(int x); return x + 3; endfunction
endpackage
package q;
  localparam int L = $clog2(p::f(4));
endpackage
module top ();
endmodule
