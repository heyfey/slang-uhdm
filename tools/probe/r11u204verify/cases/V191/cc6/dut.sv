// § evalFuncCastMemberKeepsCall191: literal actuals of a union formal (one-level and nested member reads) and of a struct formal read two levels deep
module top(output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3, output logic [1:0] o4);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } in_t;
  typedef struct packed { in_t in; logic [3:0] c; } out_t;
  typedef union packed { logic [3:0] w; in_t s; } u_t;
  function automatic logic [3:0] h1(u_t u); return u.w; endfunction
  function automatic logic [1:0] h2(u_t u); return u.s.b; endfunction
  function automatic logic [1:0] h3(out_t t); return t.in.a; endfunction
  function automatic logic [3:0] h4(out_t t); return t.c; endfunction
  assign o1 = h1(4'h6);
  assign o4 = h2(4'h6);
  assign o2 = h3(8'h96);
  assign o3 = h4(8'h96);
endmodule
