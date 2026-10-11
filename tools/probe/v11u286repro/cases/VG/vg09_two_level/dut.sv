// § genProcLvIdxCallSpan286
module top;
  logic [3:0] v [2][2];
  function automatic int fn(int a); return a; endfunction
  for (genvar i = 0; i < 2; i++) begin : a
    for (genvar j = 0; j < 2; j++) begin : b
      always_comb v[i][j][fn(i + j)] = 1'b1;
    end
  end
endmodule
