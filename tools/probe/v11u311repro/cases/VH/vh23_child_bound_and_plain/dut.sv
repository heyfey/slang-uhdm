// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y, output logic z);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  sub u (.a(q.f[i]), .y(y));
  assign z = 1'b0;
endmodule
module mon (input logic a);
endmodule
module top (output logic y, z);
  dut d (.y(y), .z(z));
  bind dut mon mb (.a(q.f[i]));
endmodule
