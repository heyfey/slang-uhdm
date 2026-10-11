// § genProcLvIdxCallSpan286
module top;
  typedef struct packed { logic f; logic g; } e_t;
  e_t [3:0] sa;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb sa[fn(1)].f = 1'b1;
  end
endmodule
