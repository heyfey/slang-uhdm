// § evalFuncCastMemberKeepsCall191: bodies casting to logic, reg, byte, signed, unsigned and a local packed struct typedef, called with constants
module top(output int o1, output int o2, output int o3, output int o4, output int o5, output int o6);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
  function automatic int g1(logic [11:0] x); return logic'(x); endfunction
  function automatic int g2(logic [11:0] x); return reg'(x); endfunction
  function automatic int g3(logic [11:0] x); return byte'(x); endfunction
  function automatic int g4(logic [11:0] x); return signed'(x); endfunction
  function automatic int g5(logic [11:0] x); return unsigned'(x); endfunction
  function automatic int g6(logic [11:0] x); return s_t'(x[7:0]); endfunction
  assign o1 = g1(12'h0f1);
  assign o2 = g2(12'h0f1);
  assign o3 = g3(12'h0f1);
  assign o4 = g4(12'h8f1);
  assign o5 = g5(12'h8f1);
  assign o6 = g6(12'h0f1);
endmodule
