// § genProcLvIdxCallSpan286
module top;
  int v [4];
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    initial for (int i = 0; i < 4; i++) v[fn(i)] = i;
  end
endmodule
