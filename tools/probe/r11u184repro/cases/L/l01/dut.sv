// § lvIdxMemberSelIsRead184: a member path ending in a select, nested in procedural lvalue indices
typedef struct packed { logic [7:0] f; logic [3:0][1:0] g; } s_t;
module top;
  s_t s;
  logic [7:0] arr;
  logic [3:0][3:0] m;
  logic b;
  int i, k;
  initial begin
    arr[s.f[i]] = 1'b1;
    arr[s.f[(i)]] <= 1'b0;
    m[s.f[i]][k] = 1'b1;
    arr[s.f[i] +: 2] = 2'b01;
    {arr[s.f[k]], b} = 2'b10;
    arr[s.g[i] + 1] = 1'b1;
  end
endmodule
