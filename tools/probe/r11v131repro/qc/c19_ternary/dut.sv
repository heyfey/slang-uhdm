// § constCtxCallArgInner131v
package p;
  function automatic int f(int x); return x * 2; endfunction
endpackage
module top ();
  parameter int W = 1;
  localparam int P = (W > 0) ? p::f(1) : 0;
endmodule
