// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (input logic [4:0] i, output logic y, output logic z);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  sub u (.a(q.f[i]), .y(y));
  sub v (.a(q.f[0]), .y(z));
endmodule
