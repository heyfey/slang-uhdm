// § defGenTargetIpsSelArm219 — a spaced indexed part-select target through an interface array element and through a struct array element in a generate
interface ifc;
  logic [7:0] s;
endinterface
typedef struct packed { logic [7:0] f; } e_t;
module top (input logic [7:0] i, output e_t [1:0] o);
  ifc u [2] ();
  e_t ea [2];
  for (genvar k = 0; k < 2; k++) begin : gl
    assign u[k].s[2 +: 4] = i[3:0];
    assign ea[k].f[1 +: 3] = i[2:0];
    assign o[k] = ea[k];
  end
endmodule
