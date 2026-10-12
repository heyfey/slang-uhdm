// § incDecIpsWholeSpan288 — an indexed part-select inc/dec operand in a class method, a module function and an always block, +: and -:, prefix and postfix; part-select, bit-select and compound assignment controls
package hp;
  class k;
    logic [7:0] pvec;
    function void a(int s); pvec[s+:2]++; endfunction
    function void b(int s); pvec[s-:2]--; endfunction
    function void c(int s); pvec[3:2]++; endfunction
    function void d(int s); pvec[s]++; endfunction
    function void e(int s); ++pvec[s+:2]; endfunction
    function void f(int s); pvec[s+:2] += 1; endfunction
  endclass
endpackage
module top(input logic [7:0] x);
  logic [7:0] q;
  function automatic void mf(int s); q[s+:2]++; endfunction
  always_comb begin q = x; q[1+:2]++; end
endmodule
