typedef struct packed { logic [3:0] v; logic [1:0][1:0] pg; logic ok; } e_t;
module dut(input logic [1:0] d, input logic k, output logic [21:0] o);
  e_t [1:0] tq;
  always_comb begin
    tq = '0;
    tq[k].pg[1][1:0] = d;
  end
  assign o = tq;
endmodule
