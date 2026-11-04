// § incDecMemberSelIsLvalue184 § incDecSelTopRestore184v: inc/dec member-select operands whose index is a call taking a member select (user call, nested call, system call, post and pre forms), and a mixed-path operand with the same index (§ incDecMixedPathIsLvalue181, control of the other law)
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][7:0] f; logic [3:0][1:0] g; } s_t;
  typedef struct packed { s_t [1:0] w; } m_t;
  s_t s;
  m_t m;
  function automatic logic [1:0] ix(input logic [1:0] x); return x; endfunction
  always @(posedge clk) begin
    s.f[ix(s.g[k])]++;
    ++s.f[ix(ix(s.g[k]))];
    s.f[$unsigned(s.g[k])]--;
    s.f[ix(s.g[k]) + 1]--;
    m.w[ix(s.g[k])].f[k]++;
  end
  assign o = s.f[0];
endmodule
