// § defGenTargetIpsSelArm219 — indexed part-select targets with a genvar-expression base and a parameter base on a member path in a for-generate
typedef struct packed { logic [15:0] f; logic v; } in_t;
module top #(parameter int P = 4) (input logic [15:0] i, output in_t o);
  assign o.v = 1'b1;
  for (genvar k = 0; k < 2; k++) begin : gl
    assign o.f[k*2 +: 2] = i[k*2 +: 2];
  end
  if (P > 0) begin : gp
    assign o.f[P +: 4] = i[7:4];
    assign o.f[15 -: 8] = i[15:8];
  end
endmodule
