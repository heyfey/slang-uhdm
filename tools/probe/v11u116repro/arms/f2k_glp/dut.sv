module dut ();
  logic clk;
  logic [127:0] q [4];
  logic [127:0] d [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    localparam int unsigned P = 32;
    for (genvar b = 0; b < 2; b++) begin : gb
      always_ff @(posedge clk) q[f][b*P+:P] <= d[f][b*P+:P];
    end
  end
endmodule
