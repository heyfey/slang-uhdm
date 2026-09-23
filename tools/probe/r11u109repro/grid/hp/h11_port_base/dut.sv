typedef struct packed { logic [3:0] v; logic [1:0][1:0] pg; logic ok; } e_t;
module dut(input e_t [1:0] tq, input logic k, output logic [1:0] o);
  assign o = tq[k].pg[1][1:0];
endmodule
