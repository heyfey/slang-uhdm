// § genProcLvIdxCallSpan286
module top (input clk, input d);
  logic [3:0] v;
  function automatic int fn(int a); return a; endfunction
  for (genvar g = 0; g < 2; g++) begin : gl
    always @(posedge clk) v[fn(g)] <= #1 d;
  end
endmodule
