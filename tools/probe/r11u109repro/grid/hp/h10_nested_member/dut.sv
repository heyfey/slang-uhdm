typedef struct packed { logic [1:0][1:0] pg; } in_t;
typedef struct packed { in_t a; logic b; } e_t;
module dut(input logic [9:0] din, input logic k, output logic [1:0] o);
  e_t [1:0] tq;
  assign tq = din;
  assign o = tq[k].a.pg[1][1:0];
endmodule
