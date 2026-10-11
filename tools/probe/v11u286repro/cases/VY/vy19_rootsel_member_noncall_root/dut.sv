// § genProcLvIdxCallSpan286
module top;
  typedef struct packed { logic [1:0] f; } e_t;
  e_t [3:0] sa;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb sa[1].f[fn(0)] = 1'b1;
  end
endmodule
