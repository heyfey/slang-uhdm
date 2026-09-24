typedef struct packed { logic [3:0] v; logic [1:0][1:0] pg; logic ok; } e_t;
module dut(input logic [21:0] din, output logic [1:0] o);
  e_t [1:0] tq;
  assign tq = din;
  assign o = tq[1].pg[0][1:0];
endmodule
