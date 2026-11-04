// § hcPathIdxBindsDefNet311
module subv (input logic [3:0] a, output logic y);
  assign y = a[0];
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f; logic [7:0] g;} st_t;
  st_t q;
  int i, j;
  subv u (.a(q.f[i -: 4] ^ {q.g[j], 3'b0}), .y(y));
endmodule
