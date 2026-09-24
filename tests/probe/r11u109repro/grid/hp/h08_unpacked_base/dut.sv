typedef struct packed { logic [3:0] v; logic [1:0][1:0] pg; logic ok; } e_t;
module dut(input logic [10:0] din, input logic k, output logic [1:0] o);
  e_t tq [2];
  assign tq[0] = din;
  assign tq[1] = din;
  assign o = tq[k].pg[1][1:0];
endmodule
