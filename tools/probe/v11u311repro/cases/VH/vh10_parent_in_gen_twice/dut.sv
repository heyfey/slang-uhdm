// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  sub u (.a(q.f[i]), .y(y));
endmodule
module top (output logic [1:0] y);
  for (genvar g = 0; g < 2; g++) begin : gg
    dut d (.y(y[g]));
  end
endmodule
