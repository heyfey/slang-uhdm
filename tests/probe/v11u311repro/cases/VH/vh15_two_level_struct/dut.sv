// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [7:0] f;} in_t;
  typedef struct packed {in_t s; logic [7:0] g;} st_t;
  st_t q;
  int i;
  sub u (.a(q.s.f[i]), .y(y));
endmodule
