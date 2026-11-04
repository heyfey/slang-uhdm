// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [7:0] f;} st_t;
  st_t [3:0] qa;
  int i, j;
  sub u (.a(qa[j].f[i]), .y(y));
endmodule
