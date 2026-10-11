// § genProcLvIdxCallSpan286
module top;
  typedef struct packed { logic [1:0] b; } e_t;
  typedef struct packed { e_t [3:0] arr; } s_t;
  s_t s;
  e_t [3:0] m;
  function automatic int fn(int a); return a; endfunction
  for (genvar i = 0; i < 2; i++) begin : gl
    always_comb s.arr[fn(i)].b = 2'b01;
  end
endmodule
