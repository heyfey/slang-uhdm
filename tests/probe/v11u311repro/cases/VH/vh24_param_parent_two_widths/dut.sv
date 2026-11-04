// § hcPathIdxBindsDefNet311
module sub #(parameter int W = 1) (input logic [W-1:0] a, output logic y);
  assign y = a[0];
endmodule
module dut #(parameter int N = 8) (output logic y);
  typedef struct packed {logic [N-1:0] f;} st_t;
  st_t q;
  logic [$clog2(N)-1:0] i;
  sub #(.W(1)) u (.a(q.f[i]), .y(y));
endmodule
module top (output logic [1:0] y);
  dut #(.N(8)) d8 (.y(y[0]));
  dut #(.N(16)) d16 (.y(y[1]));
endmodule
