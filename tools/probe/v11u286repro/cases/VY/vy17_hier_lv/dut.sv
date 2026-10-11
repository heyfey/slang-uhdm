// § genProcLvIdxCallSpan286
module leaf;
  logic [7:0] v;
endmodule
module top;
  leaf l();
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    initial l.v[fn(1)] = 1'b1;
  end
endmodule
