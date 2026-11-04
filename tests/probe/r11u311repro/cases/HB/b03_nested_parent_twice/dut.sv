// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module mid (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  sub u (.a(q.f[i]), .y(y));
endmodule
module dut (output logic [1:0] y);
  mid m0 (.y(y[0]));
  mid m1 (.y(y[1]));
endmodule
