// § bindUnresolvedPathNoName164 — a bind's ordered connection through a missing instance name
module leaf(input clk, output reg [4:0] r);
  always @(posedge clk) r <= r + 1;
endmodule
module mid(input clk);
  leaf u(.clk(clk), .r());
endmodule
module chk(input clk, input [4:0] x, input [4:0] y);
endmodule
module top(input clk);
  mid m0(.clk(clk));
endmodule
module W;
  bind top chk C(clk, m0.u.r, m0.v.r);
endmodule
