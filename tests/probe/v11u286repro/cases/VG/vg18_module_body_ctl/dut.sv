// § genProcLvIdxCallSpan286
module top;
  logic [3:0] v;
  function automatic int fn(int a); return a; endfunction
  always_comb v[fn(2)] = 1'b1;
endmodule
