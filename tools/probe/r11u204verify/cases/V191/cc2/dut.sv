// § evalFuncCastMemberKeepsCall191: bodies reading a packed union local's member, a nested struct member, and a member of another function's struct result
module top(output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t in; logic [3:0] c; } out_t;
  typedef union packed { logic [7:0] w; in_t s; } u_t;
  function automatic in_t mk(logic [7:0] x); return x; endfunction
  function automatic logic [3:0] h1(logic [7:0] x); u_t u; u.w = x; return u.s.a; endfunction
  function automatic logic [3:0] h2(logic [11:0] x); out_t t; t = x; return t.in.b; endfunction
  function automatic logic [3:0] h3(logic [7:0] x); return mk(x).a; endfunction
  assign o1 = h1(8'h5a);
  assign o2 = h2(12'h5a3);
  assign o3 = h3(8'h5a);
endmodule
