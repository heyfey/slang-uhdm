// § incDecBitSelWholeSpan181 — a bit-select inc/dec operand in always_ff inside nested generate scopes (f2_incd_d2ff's shape)
package p; parameter int unsigned P = 32; endpackage
module top import p::*; (input logic clk);
  logic [7:0] cnt [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      always_ff @(posedge clk) begin
        cnt[P%4]++;
        cnt[b]--;
      end
    end
  end
endmodule
