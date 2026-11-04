// § streamLvMemberPathRead184: a streaming lvalue whose operand is a member path ending in a select, a mixed operand list, a slice size and a class method
typedef struct packed { logic [7:0] f; logic [3:0] v; } s_t;
module top;
  s_t s;
  logic [7:0] arr [4];
  int k;
  logic [15:0] x;
  class C;
    s_t cs;
    function void g(logic [15:0] d);
      {>>{cs.f, cs.v}} = d;
    endfunction
  endclass
  initial begin
    {>>{s.f[k], arr[k]}} = x;
    {<<4{s.v}} = x;
    {>>{arr[k], s.v}} = x;
  end
endmodule
