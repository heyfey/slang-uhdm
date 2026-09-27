// § streamLvMemberPathRead184: a streaming lvalue whose single operand is a member path ending in a select, and a class method's member operands
typedef struct packed { logic [7:0] f; logic [3:0] v; } s_t;
module top;
  s_t s;
  int k;
  logic [15:0] x;
  class C;
    s_t cs;
    function void g(logic [15:0] d);
      {>>{cs.f, cs.v}} = d;
    endfunction
  endclass
  initial {>>{s.f[k]}} = x;
endmodule
