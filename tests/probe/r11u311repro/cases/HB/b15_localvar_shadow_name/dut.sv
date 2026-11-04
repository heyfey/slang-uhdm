// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module mid (input int i, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  sub u (.a(q.f[i]), .y(y));
endmodule
module dut (output logic y);
  int i;
  mid m (.i(i), .y(y));
endmodule
