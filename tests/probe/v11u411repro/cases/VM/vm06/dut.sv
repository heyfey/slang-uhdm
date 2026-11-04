// § callResultMemberDropped411
interface ifc;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic s_t mk(logic [3:0] v);
    mk = {v, ~v};
  endfunction
endinterface
module top(input logic [3:0] x, output logic [3:0] r);
  ifc u();
  assign r = u.mk(x).a;
endmodule
