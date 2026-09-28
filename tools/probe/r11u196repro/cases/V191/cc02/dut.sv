// § evalFuncCastMemberKeepsCall191: a member read of a function local struct keeps the call, a literal pattern actual folds, a module parameter member keeps
module top(output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t PS = '{a: 4'h1, b: 4'h2};
  function automatic logic [3:0] h1(logic [7:0] x); s_t t; t = x; return t.b; endfunction
  function automatic logic [3:0] h2(s_t v); return v.a; endfunction
  function automatic logic [3:0] h3(logic [3:0] y); return PS.a ^ y; endfunction
  assign o1 = h1(8'h21);
  assign o2 = h2('{a: 4'h5, b: 4'h6});
  assign o3 = h3(4'h3);
endmodule
