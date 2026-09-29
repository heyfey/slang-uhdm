// § defGenTargetIpsSelArm219 — a parameter-expression base and a parenthesized base on indexed part-select targets in a generate block
typedef struct packed { logic [7:0] f; logic v; } in_t;
typedef struct packed { in_t s; logic w; } s_t;
module top #(parameter int P = 1) (input logic [3:0] i, output s_t o);
  assign o.w = 1'b0;
  assign o.s.v = 1'b1;
  assign o.s.f[1:0] = 2'd0;
  if (P > 0) begin : g
    assign o.s.f[P*2+:2] = i[1:0];
    assign o.s.f[(P+6)-:3] = i[3:1];
  end
endmodule
