// § genScopeTrailSelNameLate184: a generate block's process with a named begin and a local index
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1) (input logic clk, input int i);
  s_t s, t;
  if (P) begin : gb
    always_ff @(posedge clk) begin : nb
      int j;
      j = i;
      t.f[j] <= s.f[j];
    end
  end
endmodule
