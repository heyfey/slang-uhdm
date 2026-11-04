// § varSelIdxHpLeafByPath306
package pk;
  typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
  typedef struct packed { logic [15:0][7:0] f; } s_t;
  s_t s; t_t t; logic [3:0] m2 [4][4];
  function automatic logic [7:0] g(logic [3:0] n); return s.f[n + m2[1][t.k]]; endfunction
endpackage
module top(input logic [3:0] n, output logic [7:0] r);
  assign r = pk::g(n);
endmodule
