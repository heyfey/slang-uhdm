// § ifaceCallResultMemberElem413
interface ifc;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic s_t mk(logic [3:0] v);
    mk = {v, ~v};
  endfunction
  function automatic s_t mk2(logic [3:0] v, logic [3:0] w);
    mk2 = {v, w};
  endfunction
  function automatic s_t g();
    g = 8'h5a;
  endfunction
endinterface
module top(input logic [3:0] x, output logic [7:0] r);
  ifc u();
  assign r = u.mk(x);
endmodule
