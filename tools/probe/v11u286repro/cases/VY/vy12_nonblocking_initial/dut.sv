// § genProcLvIdxCallSpan286
module top;
  logic [7:0] v;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    initial v[fn(5)] <= 1'b1;
  end
endmodule
