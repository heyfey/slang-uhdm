typedef struct packed { logic [3:0] v; logic [1:0][1:0] pg; logic ok; } e_t;
module dut(input logic [21:0] din, output logic [3:0] o);
  e_t [1:0] tq;
  assign tq = din;
  for (genvar gi = 0; gi < 2; gi++) begin : g
    for (genvar gx = 1; gx < 3; gx++) begin : h
      assign o[gi*2+gx-1] = &tq[gi].pg[2-gx][0:0];
    end
  end
endmodule
