// § rootLvalueSpanAtRoot184: $root path targets: nonblocking, compound, a struct member, a deeper path, a macro, and a select target
typedef struct packed { logic [3:0] f; } s_t;
module top; logic [3:0] v; s_t m; logic clk; sub u(); endmodule
module sub;
  logic [3:0] x;
  `define RT $root.top.v
  always @(posedge $root.top.clk) $root.top.v <= 4'd2;
  initial begin
    $root.top.v += 4'd1;
    $root.top.m.f = 4'd3;
    $root.top.u.x = 4'd4;
    `RT = 4'd5;
    $root.top.v[2] <= 1'b1;
    $root.top.m.f[1] = 1'b0;
  end
endmodule
