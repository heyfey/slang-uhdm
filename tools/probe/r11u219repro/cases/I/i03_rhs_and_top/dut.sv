// § defGenTargetIpsSelArm219 — a spaced indexed part select read on the right side inside a generate block, and a spaced target outside any generate block
typedef struct packed { logic [7:0] f; logic v; } in_t;
module top #(parameter bit P = 1) (input in_t a, output logic [1:0] o, output logic [7:0] q);
  assign q[1 +: 2] = a.f[3 +: 2];
  assign q[0] = 1'b0;
  assign q[7:3] = '0;
  if (P) begin : g
    assign o = a.f[5 -: 2];
  end
endmodule
