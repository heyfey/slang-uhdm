// § genProcLvIdxCallSpan286
module top;
  logic [3:0] v;
  logic w;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb {v[fn(0)], w} = 2'b11;
  end
endmodule
