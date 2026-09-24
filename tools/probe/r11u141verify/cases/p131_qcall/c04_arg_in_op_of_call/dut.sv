// § constCtxCallArgInner131v
// case c04: package call inside an operation that is itself a system-call argument
package p;
  function automatic int f(int a);
    return a + 3;
  endfunction
endpackage
module sub #(parameter int P = $clog2(p::f(5) + 1)) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
