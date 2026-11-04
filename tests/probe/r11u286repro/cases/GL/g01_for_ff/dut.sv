// § genProcLvIdxCallSpan286 — for-generate always_ff, two-level select with a call index (the witness shape)
module dut ();
  parameter int P = 3;
  logic clk;
  logic [127:0] d [4];
  logic [63:0] v [4];
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 2; f++) begin : gf
    always_ff @(posedge clk) begin
      v[f][fn(P)] <= d[f][0];
    end
  end
endmodule
