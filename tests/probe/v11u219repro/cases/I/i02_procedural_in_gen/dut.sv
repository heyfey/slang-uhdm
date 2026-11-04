// § defGenTargetIpsSelArm219 — spaced indexed part selects on a member path written procedurally inside a generate block and as a right side
typedef struct packed { logic [7:0] f; logic v; } in_t;
module top (input logic [7:0] i, output in_t o, output logic [1:0] r);
  in_t t;
  if (1) begin : g
    always_comb begin
      t = '0;
      t.f[2 +: 2] = i[1:0];
      o = t;
    end
    assign r = t.f[4 +: 2];
  end
endmodule
