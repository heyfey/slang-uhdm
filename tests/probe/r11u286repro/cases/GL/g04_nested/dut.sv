// § genProcLvIdxCallSpan286 — two-level for-generate with genvar and parameter call arguments
module dut ();
  parameter int P = 3;
  logic clk;
  logic [63:0] v [4];
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      always_ff @(posedge clk) v[f][fn(b)] <= 1'b1;
    end
  end
endmodule
