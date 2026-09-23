module dut #(parameter int unsigned P = 32) ();
  logic clk;
  logic [127:0] q [4];
  logic [127:0] d [4];
  logic [63:0] v [4];
  logic [7:0] cnt [4];
  typedef struct packed { logic [31:0] x; } s_t;
  s_t s [64];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
        always_ff @(posedge clk) begin
          q[f][b*P+:P] <= d[f][b*P+:P];
        end
    end
  end
endmodule
