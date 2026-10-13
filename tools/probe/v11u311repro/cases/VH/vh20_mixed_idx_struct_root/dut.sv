// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [3:0][7:0] f;} st_t;
  st_t q;
  int i, j;
  sub u (.a(q.f[i][j]), .y(y));
endmodule
