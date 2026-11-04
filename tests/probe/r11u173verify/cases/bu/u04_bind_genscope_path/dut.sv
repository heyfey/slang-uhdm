// § bindUnresolvedPathNoName164 — an unresolvable path through a generate scope of the bind target
module leaf(input clk, output reg [4:0] r);
  always @(posedge clk) r <= r + 1;
endmodule
module mid(input clk);
  if (1) begin : g
    leaf u(.clk(clk), .r());
  end
endmodule
module chk(input clk, input [4:0] x, input [4:0] y);
endmodule
module top(input clk);
  mid m0(.clk(clk));
endmodule
module W;
  bind top chk C(.clk(clk), .x(m0.g.u.r), .y(m0.g.v.r));
endmodule
