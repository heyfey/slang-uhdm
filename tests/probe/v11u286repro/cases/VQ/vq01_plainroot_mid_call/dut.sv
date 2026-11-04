// § genProcLvIdxCallSpan286
module top;
  typedef struct packed { logic [1:0] b; } e_t;
  typedef struct packed { e_t [3:0] arr; } s_t;
  s_t s;
  e_t [3:0] m;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb s.arr[fn(1)].b = 2'b01;
  end
endmodule
