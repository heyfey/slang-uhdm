// § incDecMemberSelIsLvalue184 § incDecSelTopRestore184v: inc/dec member-select operands whose index is a call, a call whose argument is a member select, and a parenthesized unary index, in a module function and an always block
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][7:0] f; logic [3:0][7:0] g; } s_t;
  s_t s;
  function automatic logic [1:0] ix(input logic [7:0] x); return x[1:0]; endfunction
  function automatic void bump(input logic [1:0] j);
    s.f[ix(j)]++;
    --s.g[ix(s.f[j])];
    s.f[(-j)]--;
  endfunction
  always @(posedge clk) begin
    s.g[ix(k)]++;
    bump(k);
  end
  assign o = s.f[0];
endmodule
