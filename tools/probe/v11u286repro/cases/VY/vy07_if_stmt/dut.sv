// § genProcLvIdxCallSpan286
module top;
  logic [7:0] v;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb if (v[0]) v[fn(3)] = 1'b1; else v[fn(4)] = 1'b0;
  end
endmodule
