// § lvIdxMemberSelIsRead184 § nestRdIdxOnly190v § lvIdxMixedPathIsRead181: call arguments inside lvalue index paths: a member select as a call argument in the index, a member select whose index is a call of a member select, and a mixed path in a call argument
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  typedef struct packed { s_t [1:0] w; } m_t;
  s_t s, t;
  m_t m;
  logic [7:0] arr;
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  always @(posedge clk) begin
    arr[fx(s.f[k])] <= 1'b1;
    arr[fx(m.w[k].f[k])] <= 1'b1;
  end
  assign o = arr;
endmodule
