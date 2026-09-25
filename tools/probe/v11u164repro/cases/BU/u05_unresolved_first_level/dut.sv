// § bindUnresolvedPathNoName164 — a bind path whose first component does not exist
module leaf(input clk, output reg [4:0] r);
  always @(posedge clk) r <= r + 1;
endmodule
module chk(input clk, input [4:0] x);
endmodule
module top(input clk);
  leaf u(.clk(clk), .r());
endmodule
module W;
  bind top chk C(.clk(clk), .x(nope.r));
endmodule
