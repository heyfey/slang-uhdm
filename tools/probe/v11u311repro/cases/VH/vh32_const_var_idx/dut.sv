// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i = 3;
  sub u (.a(q.f[i]), .y(y));
endmodule
