// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic [3:0] x, output logic [7:0] o);
  typedef struct packed { logic [7:0] wdtxx; } s_t;
  s_t sv;
  always_ff @(posedge clk) {sv.wdtxx[7:4], sv.wdtxx[3:0]} <= {x, x};
  assign o = sv;
endmodule
