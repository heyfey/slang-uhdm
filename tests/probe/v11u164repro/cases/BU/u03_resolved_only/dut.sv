// § bindUnresolvedPathNoName164 — a bind's named connections all resolvable (control)
module leaf(input clk, output reg [4:0] r);
  always @(posedge clk) r <= r + 1;
endmodule
module mid(input clk);
  leaf u(.clk(clk), .r());
endmodule
module chk(input clk, input [4:0] x);
endmodule
module top(input clk);
  mid m0(.clk(clk));
endmodule
module W;
  bind top chk C(.clk(clk), .x(m0.u.r));
endmodule
