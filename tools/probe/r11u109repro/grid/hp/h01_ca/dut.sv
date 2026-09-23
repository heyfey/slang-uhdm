typedef struct packed { logic [3:0] v; logic [1:0][1:0] pg; logic ok; } e_t;
module dut(input logic [21:0] din, input logic [1:0] k, output logic o);
  e_t [1:0] tq;
  assign tq = din;
  assign o = |tq[k[0]].pg[k[1]][1:0];
endmodule
