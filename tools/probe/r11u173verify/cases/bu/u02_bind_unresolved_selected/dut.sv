// § bindUnresolvedPathNoName164 — an unresolvable path with a bit select on its leaf
module leaf(input clk, output reg [4:0] r);
  always @(posedge clk) r <= r + 1;
endmodule
module mid(input clk);
  leaf u(.clk(clk), .r());
endmodule
module chk(input clk, input x, input y);
endmodule
module top(input clk);
  mid m0(.clk(clk));
endmodule
module W;
  bind top chk C(.clk(clk), .x(m0.u.r[0]), .y(m0.w.r[1]));
endmodule
