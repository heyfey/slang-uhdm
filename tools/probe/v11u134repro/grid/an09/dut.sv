// § anonMemberRefChainName134
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed {
    struct packed { struct packed { logic [1:0] p, q; } lo; } mid;
  } s_t;
  s_t s1;
  s_t s2;
  assign s1 = i;
  assign s2 = s1;
  assign o = {s2.mid.lo.p, s1.mid.lo.q};
endmodule
