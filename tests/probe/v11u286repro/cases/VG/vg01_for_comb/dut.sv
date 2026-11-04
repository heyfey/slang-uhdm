// § genProcLvIdxCallSpan286
module top;
  logic [3:0] v [2];
  function automatic int fn(int a); return a; endfunction
  for (genvar g = 0; g < 2; g++) begin : gl
    always_comb v[g][fn(g)] = 1'b1;
  end
endmodule
