// § defGenTargetIpsDefName205 — r11u217 i03: indexed part selects as generate-assignment targets with a PARAMETER expression base `o.f[P*2+:2]`, a genvar base `o.g[k*2+:2]` (the known residue R3) and a literal base in the same loop
typedef struct packed { logic [7:0] f; logic [7:0] g; logic [7:0] h; } s_t;
module top #(parameter int P = 1) (input logic [7:0] i, output s_t o);
  assign o.f[1:0] = 2'd0;
  assign o.f[7:4] = 4'd0;
  assign o.h[7:2] = 6'd0;
  for (genvar k = 0; k < 4; k++) begin : gl
    assign o.g[k*2+:2] = i[k*2+:2];
  end
  if (P == 1) begin : gp
    assign o.f[P*2+:2] = i[1:0];
    assign o.h[0+:2] = i[3:2];
  end
endmodule
