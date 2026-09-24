// § constCtxCallArgInner131v
package p;
  function automatic int f(int x); return x * 2; endfunction
  function automatic int g(int x); return x + 3; endfunction
endpackage
module top ();
  localparam int P = p::g(p::f(1));
endmodule
