// § bindUnresolvedPathNoName164 — a module-type bind whose target has two instances, one connection unresolvable
module leaf(input clk, output reg [3:0] r);
  always @(posedge clk) r <= r + 1;
endmodule
module mid(input clk);
  leaf u(.clk(clk), .r());
endmodule
module chk(input clk, input [3:0] x, input [3:0] y);
endmodule
module top(input clk);
  mid m0(.clk(clk));
  mid m1(.clk(clk));
endmodule
module W;
  bind mid chk C(.clk(clk), .x(u.r), .y(u.q.r));
endmodule
