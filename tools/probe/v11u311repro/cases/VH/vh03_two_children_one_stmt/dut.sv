// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y0, y1);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i, j;
  sub u0 (.a(q.f[i]), .y(y0)), u1 (.a(q.f[j]), .y(y1));
endmodule
