// § genProcLvIdxCallSpan286
module top;
  logic [3:0][3:0] v2;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb v2[fn(1)][fn(2)] = 1'b1;
  end
endmodule
