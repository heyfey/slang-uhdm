// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic [3:0] x);
  typedef struct packed { logic [7:0] wdtxx; logic [7:0] q; } s_t;
  s_t sv;
  task automatic t1(input logic [3:0] a); sv.q[3:0] = a; endtask
  always_ff @(posedge clk) t1(x);
endmodule
