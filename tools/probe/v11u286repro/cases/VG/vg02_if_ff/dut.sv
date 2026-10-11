// § genProcLvIdxCallSpan286
module top #(parameter P = 1) (input clk, input d);
  logic [3:0] v;
  function automatic int fn(int a); return a; endfunction
  if (P == 1) begin : gi
    always_ff @(posedge clk) v[fn(1)] <= d;
  end
endmodule
