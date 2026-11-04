// § genProcLvIdxCallSpan286
module top (input clk, input [1:0] d);
  logic [7:0] v [2];
  function automatic int fn(int a); return a; endfunction
  for (genvar g = 0; g < 2; g++) begin : gl
    always_ff @(posedge clk) begin
      v[g][fn(g)] <= d[0];
      v[g][fn(g) + 1] <= d[1];
    end
  end
endmodule
