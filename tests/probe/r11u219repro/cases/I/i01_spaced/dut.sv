// § defGenTargetIpsSelArm219 — spaced indexed part-select targets `[2 +: 2]` / `[7 -: 3]` on a two-level member in an if-in-for generate
typedef struct packed { logic [7:0] f; logic v; } in_t;
typedef struct packed { in_t s; logic w; } s_t;
module top #(parameter bit P = 1) (input logic [3:0] i, output s_t o);
  assign o.w = 1'b0;
  assign o.s.v = 1'b1;
  assign o.s.f[1:0] = 2'd0;
  assign o.s.f[4] = 1'b0;
  for (genvar k = 0; k < 1; k++) begin : gl
    if (P) begin : gi
      assign o.s.f[2  +:  2] = i[1:0];
      assign o.s.f[7 -: 3] = i[3:1];
    end
  end
endmodule
