// § trailIdxCallArgNamesByPath187 (a path inside a ternary and a call argument)
module top(input int k, input logic c, output logic y, output int z);
  typedef struct packed { logic [7:0] q; } m_t;
  m_t m;
  function automatic int f(int x); return x; endfunction
  function automatic int g(logic x); return x; endfunction
  assign y = c ? m.q[f(k)] : 1'b0;
  assign z = g(m.q[f(k)]);
endmodule
