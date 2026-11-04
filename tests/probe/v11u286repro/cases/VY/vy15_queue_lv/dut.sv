// § genProcLvIdxCallSpan286
module top;
  int qq[$] = '{1};
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    initial qq[fn(0)] = 3;
  end
endmodule
