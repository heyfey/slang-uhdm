// § defGenTargetIpsDefName205 — r11u217 i04: a MIDDLE indexed part select (not the target's last element) and a whole-member target beside an indexed part-select target in one if-generate, with an `else` branch writing the same member by a range select
typedef struct packed { logic [3:0] f; logic [3:0] g; } in_t;
typedef struct packed { in_t [1:0] a; logic v; } s_t;
module top #(parameter bit P = 0) (input logic [3:0] i, output s_t o);
  assign o.v = 1'b0;
  assign o.a[0] = '0;
  if (P) begin : gt
    assign o.a[1].f[1+:3] = i[2:0];
    assign o.a[1].f[0] = 1'b0;
    assign o.a[1].g = i;
  end else begin : ge
    assign o.a[1].f[3:1] = i[3:1];
    assign o.a[1].f[0] = 1'b1;
    assign o.a[1].g[3-:4] = i;
  end
endmodule
