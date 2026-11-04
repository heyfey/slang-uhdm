// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (input logic s, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i, j;
  sub u (.a(q.f[s ? i : j]), .y(y));
endmodule
