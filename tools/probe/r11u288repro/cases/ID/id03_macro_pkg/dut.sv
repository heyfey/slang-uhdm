// § incDecIpsWholeSpan288 — a macro-born operand, a package function, an interface function and a class property through this
`define BUMP(v, b) v[b +: 2]++
package ip;
  logic [7:0] pv;
  function automatic void pf(int s); pv[s +: 2]--; endfunction
endpackage
interface ifc;
  logic [7:0] iv;
  function automatic void bump(int s); iv[s -: 2]++; endfunction
endinterface
class cc;
  logic [7:0] m;
  function void f(int s); this.m[s +: 2]++; ++m[s +: 3]; endfunction
endclass
module top(input logic [2:0] k);
  logic [7:0] q;
  ifc u_if();
  always_comb begin q = '0; `BUMP(q, k); end
endmodule
