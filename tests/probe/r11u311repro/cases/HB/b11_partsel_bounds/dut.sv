// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module subv (input logic [1:0] a, output logic y);
  assign y = a[0];
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  subv u (.a(q.f[i+:2]), .y(y));
endmodule
