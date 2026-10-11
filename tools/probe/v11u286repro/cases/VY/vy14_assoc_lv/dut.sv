// § genProcLvIdxCallSpan286
module top;
  int aa[int];
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    initial aa[fn(1)] = 3;
  end
endmodule
