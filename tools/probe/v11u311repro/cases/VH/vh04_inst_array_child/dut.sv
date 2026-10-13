// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic [1:0] y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  sub u [1:0] (.a(q.f[i]), .y(y));
endmodule
