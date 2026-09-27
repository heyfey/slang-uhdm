// § lvIdxMemberSelIsRead184: a member-select read nested in a member-path target's index, in a two-index target, and in a function
typedef struct packed { logic [3:0] f; } s_t;
typedef struct packed { logic [15:0] g; } t_t;
module top (input logic clk);
  s_t s;
  t_t s2;
  logic [15:0] arr;
  logic [3:0] m2 [4][4];
  int i, j;
  function automatic void wr(int k);
    arr[s.f[k]] = 1'b1;
  endfunction
  always_ff @(posedge clk) begin
    s2.g[s.f[i]] <= 1'b1;
    m2[s.f[i]][s.f[j]] <= 4'd1;
  end
  initial arr[s.f[(i)] +: 2] = 2'b01;
endmodule
