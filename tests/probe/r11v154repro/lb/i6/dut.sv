// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic [3:0] x);
  typedef struct packed { logic [7:0] wdtxx; logic [7:0] q; } s_t;
  generate if (1) begin : g
    s_t sv;
    always_ff @(posedge clk) sv.wdtxx[3:0] <= x;
  end endgenerate
endmodule
