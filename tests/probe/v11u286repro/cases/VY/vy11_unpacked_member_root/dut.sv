// § genProcLvIdxCallSpan286
module top;
  typedef struct { logic arr [4]; } u_t;
  u_t us;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb us.arr[fn(1)] = 1'b1;
  end
endmodule
