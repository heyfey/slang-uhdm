// § anonMemberRefChainName134
module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed {
    union packed { logic [3:0] w; struct packed { logic [1:0] h, l; } p; } u;
    enum logic [3:0] { X0, X1 } kind;
  } s_t;
  s_t s;
  always_comb begin s.u.w = i[3:0]; s.kind = s.kind.first; end
  assign o = {s.u.p.h, s.u.p.l} ^ s.kind;
endmodule
