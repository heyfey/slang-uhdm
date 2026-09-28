// § lvIdxMemberSelIsRead184 § nestRdIdxOnly190v: a member select whose index is a call of another member select, nested in an lvalue index (r11v184 R4 family)
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  typedef struct packed { s_t [1:0] w; } m_t;
  s_t s, t;
  m_t m;
  logic [7:0] arr;
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  always @(posedge clk) begin
    arr[s.f[fx(t.f[k])]] <= 1'b0;
  end
  assign o = arr;
endmodule
