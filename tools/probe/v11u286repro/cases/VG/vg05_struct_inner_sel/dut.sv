// § genProcLvIdxCallSpan286
module top;
  typedef struct packed { logic [3:0] b; } e_t;
  typedef struct packed { e_t [1:0] arr; } s_t;
  s_t s;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb s.arr[1].b[fn(2)] = 1'b1;
  end
endmodule
