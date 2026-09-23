typedef struct packed { logic [3:0] v; logic [1:0][1:0] pg; logic ok; } e_t;
module dut(input logic [43:0] din, input logic k, output logic [1:0] o);
  e_t [1:0][1:0] tq;
  assign tq = din;
  assign o = tq[k][0].pg[1][1:0];
endmodule
