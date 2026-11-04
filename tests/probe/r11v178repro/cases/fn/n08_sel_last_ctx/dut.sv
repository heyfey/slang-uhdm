// § refFullNameThroughNamedExpr175
package p;
  typedef struct packed { logic [3:0][7:0] x; } s_t;
  function automatic logic [7:0] pf(s_t m, int k); return m.x[k]; endfunction
endpackage
interface ifc;
  p::s_t m;
  function automatic logic [7:0] g(int k); return m.x[k]; endfunction
endinterface
class C;
  p::s_t m;
  function logic [7:0] f(int k); return m.x[k] + this.m.x[k+1]; endfunction
  task t(int k); m.x[k] = 1; endtask
endclass
module top;
  p::s_t m;
  logic [7:0] r;
  ifc i();
  function automatic logic [7:0] mf(int k); return m.x[k]; endfunction
  task automatic mt(int k); r = m.x[k]; m.x[k] = r; endtask
  if (1) begin : G
    function automatic logic [7:0] gf(int k); return m.x[k]; endfunction
  end
  initial begin r = mf(1); mt(2); r = G.gf(0); r = i.g(1); r = p::pf(m, 1); r = m.x[r]; end
endmodule
