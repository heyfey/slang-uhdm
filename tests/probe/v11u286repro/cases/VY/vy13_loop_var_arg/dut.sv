// § genProcLvIdxCallSpan286
module top;
  logic [7:0] v;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb for (int k = 0; k < 2; k++) v[fn(k)] = 1'b0;
  end
endmodule
