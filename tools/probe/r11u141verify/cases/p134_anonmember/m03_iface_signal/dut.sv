// § anonMemberRefChainName134
// case m03: a struct with an anonymous member union, as an interface signal
interface ifc;
  typedef struct packed {
    union packed { logic [3:0] n; logic [1:0][1:0] d; } u;
    logic en;
  } s_t;
  s_t s;
endinterface
module top(input logic [4:0] i, output logic [3:0] o);
  ifc x();
  assign x.s = i;
  assign o = x.s.u.n;
endmodule
