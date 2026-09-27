// § trailIdxCallArgNamesByPath187 (system calls with a variable and with an expression)
module top;
  typedef struct { logic [15:0] q; } m_t;
  m_t m;
  int k;
  logic [3:0] v;
  logic r1, r2, r3;
  initial begin
    r1 = m.q[$signed(v)];
    r2 = m.q[$countones(v)];
    r3 = m.q[$unsigned(k[3:0])];
  end
endmodule
