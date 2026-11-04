// § hpIdxCallNameSpan184 § trailIdxCallArgNamesByPath187 § trailIdxSelNamesByPath187: a call in a non-trailing index beside a call (with a path argument) under the trailing select, and a trailing member select whose index call reads a select
module top (input int k, output logic a, output logic b, output logic c);
  typedef struct packed { logic [3:0] v; } e_t;
  typedef struct packed { e_t [1:0] w; logic [3:0] q; } m_t;
  m_t m;
  logic [3:0] ix;
  function automatic int f(input int x); return x & 1; endfunction
  always_comb begin
    a = m.w[f(k)].v[f(k)];
    b = m.q[f(ix[k])];
    c = m.w[f(ix[1])].v[ix[0]];
  end
endmodule
