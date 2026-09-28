// § lvIdxMemberSelIsRead184 § streamLvMemberPathRead184: streaming lvalues whose operand is a select indexed by a member path ending in a select, and a member path ending in a select as a streaming operand
module top (input logic [15:0] x, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][1:0] f; } s_t;
  typedef struct packed { logic [3:0][7:0] w; } t_t;
  s_t s;
  logic [3:0][7:0] arr;
  t_t m;
  always_comb begin
    {>>{arr[s.f[k]]}} = x[7:0];
    {<<{m.w[k]}} = x[15:8];
  end
  assign o = arr[0] ^ m.w[0];
endmodule
