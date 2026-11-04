// § genProcLvIdxCallSpan286
module top;
  typedef struct packed { logic [3:0] b; } s_t;
  s_t s;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb s.b[fn(1)] = 1'b1;
  end
endmodule
