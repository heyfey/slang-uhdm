// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (input int i, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  sub u (.a(q.f[i]), .y(y));
endmodule
module top (input int i, output logic y);
  dut d (.i(i), .y(y));
endmodule
