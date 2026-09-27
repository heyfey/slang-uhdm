// § trailIdxCallArgNamesByPath187 (conditions, case and a concatenation lvalue)
module top(input int k, output logic y, output logic z);
  typedef struct packed { logic [7:0] q; } m_t;
  m_t m;
  function automatic int f(int x); return x; endfunction
  always_comb begin
    y = 0;
    if (m.q[f(k)]) y = 1;
    case (m.q[f(k) + 1]) 1'b1: z = 1; default: z = 0; endcase
  end
  logic a;
  always_comb {m.q[f(k)], a} = 2'b10;
endmodule
