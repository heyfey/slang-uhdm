// § ifaceCallResultMemberElem413
interface ifc;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic s_t mk(logic [3:0] v);
    mk = {v, ~v};
  endfunction
  function automatic s_t mk2(logic [3:0] v, logic [3:0] w);
    mk2 = {v, w};
  endfunction
endinterface
module sub(ifc p, input logic [3:0] x, output logic [3:0] r);
  assign r = p.mk(x).a;
endmodule
module top(input logic [3:0] x, output logic [3:0] r);
  ifc u();
  sub s(.p(u), .x(x), .r(r));
endmodule
