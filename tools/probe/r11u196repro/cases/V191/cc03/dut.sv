// § evalFuncCastMemberKeepsCall191: a generate-scope continuous assignment calling a cast-bodied function, and a size cast that folds
module top(output int o1, output int o2);
  typedef logic [7:0] l8_t;
  function automatic int g(logic [11:0] x); g = l8_t'(x); endfunction
  function automatic int k(logic [11:0] x); k = 8'(x); endfunction
  if (1) begin : gb
    assign o1 = g(12'h0f0);
  end
  assign o2 = k(12'h0f0);
endmodule
