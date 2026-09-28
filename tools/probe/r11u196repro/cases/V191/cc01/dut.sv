// § evalFuncCastMemberKeepsCall191: casts to a reg typedef and a packed union keep the call, a shortint and longint cast fold
module top(output int o1, output int o2, output int o3, output int o4);
  typedef reg [7:0] r8_t;
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  function automatic int g1(logic [11:0] x); g1 = r8_t'(x);     endfunction
  function automatic int g2(logic [11:0] x); g2 = u_t'(x);      endfunction
  function automatic int g3(logic [11:0] x); g3 = shortint'(x); endfunction
  function automatic int g4(logic [11:0] x); g4 = longint'(x);  endfunction
  assign o1 = g1(12'h123);
  assign o2 = g2(12'h123);
  assign o3 = g3(12'h123);
  assign o4 = g4(12'h123);
endmodule
