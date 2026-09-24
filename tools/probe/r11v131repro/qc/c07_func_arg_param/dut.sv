// § constCtxCallArgInner131v
package p;
  function automatic int f(int x); return x + 1; endfunction
  function automatic int g(int x); return x * 3; endfunction
endpackage
module top (output logic [31:0] o);
  localparam int P = p::g(p::f(1));
  assign o = P;
endmodule
