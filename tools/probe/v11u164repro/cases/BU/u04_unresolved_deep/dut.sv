// § bindUnresolvedPathNoName164 — a four-level unresolvable bind path
module leaf(input clk, output reg [4:0] r);
  always @(posedge clk) r <= r + 1;
endmodule
module mid(input clk);
  leaf u(.clk(clk), .r());
endmodule
module mid2(input clk);
  mid k(.clk(clk));
endmodule
module chk(input clk, input [4:0] x, input [4:0] y);
endmodule
module top(input clk);
  mid2 m0(.clk(clk));
endmodule
module W;
  bind top chk C(.clk(clk), .x(m0.k.u.r), .y(m0.k.w.r));
endmodule
