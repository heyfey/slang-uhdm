// § constCtxCallArgInner131v
package p;
  function automatic int f(int x); return x * 2; endfunction
endpackage
module top (output logic [31:0] o);
  localparam int P = $clog2(p::f(5));
  assign o = P;
endmodule
